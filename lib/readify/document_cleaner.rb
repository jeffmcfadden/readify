module Readify
  class DocumentCleaner

    def initialize
    end

    def clean(html)
      @html = html
      title, body = cleaned_html(@html)

      <<-HTML
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>#{title}</title>
        </head>
        #{body}
      </html>
      HTML
    end

    private

    def cleaned_html(html)
      doc = Nokogiri::HTML(html)

      title_node = doc.at('title')
      title = title_node ? title_node.text.strip : ""

      body = doc.at('body')
      content = nil

      if body
        # Use the main_content_node method to find the primary content
        content = main_content_node(body)

        # Apply second-pass cleaning to the content
        if content
          clean_node(content)
        end
      end

      [title, content]
    end

    # First pass: Remove elements that are definitely not content
    def prune_obvious_junk(node)
      node.children.to_a.each do |child|
        if child.element?
          # Recurse first
          prune_obvious_junk(child)

          # Remove if it's obvious junk
          if obvious_junk?(child)
            child.remove
          end
        end
      end

      node
    end

    # Returns true if this element is definitely not content
    def obvious_junk?(node)
      tag = node.name.downcase

      # Always remove these tags
      return true if %w(script style link iframe noscript).include?(tag)

      # Remove hidden elements
      return true if node['aria-hidden'] == 'true'

      # Remove display:none elements
      style = node['style'].to_s.downcase
      return true if style.include?('display:none') || style.include?('display: none')

      # Remove structural navigation
      return true if %w(nav header footer).include?(tag)
      return true if node['role'].to_s.downcase == 'navigation'

      false
    end

    # Scores a node based on how likely it is to be main content
    # Higher scores indicate more likely to be the primary article content
    def score_node(node)
      return 0 unless node.element?

      score = 0
      tag = node.name.downcase

      # Positive indicators for main content
      score += 100 if tag == 'article'
      score += 50 if tag == 'main'
      score += 25 if node['role'].to_s.downcase == 'main'

      # Count paragraphs - strong indicator of article content
      paragraph_count = node.xpath('.//p').count
      score += paragraph_count * 5

      # Calculate text length
      begin
        text_content = node.xpath('.//text()').map(&:text).join
        text_length = text_content.strip.length
        score += (text_length / 100).to_i  # 1 point per 100 characters
      rescue StandardError
        text_length = 0
      end

      # Calculate link density (high link density suggests navigation)
      link_count = node.xpath('.//a').count
      if text_length > 0
        link_density = (link_count.to_f / (text_length / 100.0))
        score -= (link_density * 10).to_i  # Penalize high link density
      end

      # Bonus for images/figures (suggests article content)
      media_count = node.xpath('.//img | .//picture | .//figure').count
      score += media_count * 10

      # Bonus for long paragraphs
      begin
        long_paragraphs = node.xpath('.//p').select { |p| p.text.strip.length > 100 }.count
        score += long_paragraphs * 15
      rescue StandardError
        # Do nothing
      end

      # Bonus for blockquotes and lists (often in articles)
      score += node.xpath('.//blockquote').count * 10
      score += node.xpath('.//ul | .//ol').count * 5

      # Penalty for suspicious classes/ids
      classes = node['class'].to_s.downcase
      ids = node['id'].to_s.downcase

      score -= 50 if classes.include?('sidebar') || ids.include?('sidebar')
      score -= 50 if classes.include?('comment') || ids.include?('comment')
      score -= 70 if classes.include?('ad') || ids.include?('ad')
      score -= 70 if classes.include?('social') || ids.include?('social')

      [score, 0].max  # Don't return negative scores
    end

    # Finds the node with the highest content score
    # Returns the node with the highest score in the tree
    def find_highest_scoring_node(node)
      return nil unless node.element?

      best_node = node
      best_score = score_node(node)

      # Recursively check all child elements
      node.children.each do |child|
        next unless child.element?

        candidate = find_highest_scoring_node(child)
        if candidate
          candidate_score = score_node(candidate)
          if candidate_score > best_score
            best_node = candidate
            best_score = candidate_score
          end
        end
      end

      best_node
    end

    # Finds an appropriate root ancestor for the given node
    # Traverses up the tree to find a good container for the main content
    # Stops at body or when we find a semantic container
    def find_content_root(node)
      return node if node.nil? || node.name.downcase == 'body'

      current = node
      best_ancestor = node

      # Traverse up the tree
      while current.parent && current.parent.element?
        parent = current.parent
        parent_tag = parent.name.downcase

        # Stop at body
        break if parent_tag == 'body'

        # Prefer semantic containers
        if %w(article main section).include?(parent_tag)
          best_ancestor = parent
        end

        # If parent has significantly more content than current node,
        # it might be a better root (captures related content)
        parent_score = score_node(parent)
        current_score = score_node(current)

        # Only move up if parent score is meaningfully higher
        # (not just marginally better due to including the child)
        if parent_score > current_score * 1.3
          best_ancestor = parent
        end

        current = parent
      end

      best_ancestor
    end

    # Returns the main content node using all heuristics
    # This is the primary method to identify the core article content
    def main_content_node(body)
      return nil unless body

      # First, remove obvious junk to clean up the tree
      prune_obvious_junk(body)

      # Find the highest-scoring node in the cleaned tree
      highest_scoring = find_highest_scoring_node(body)
      return nil unless highest_scoring

      # Find the appropriate root container for that node
      content_root = find_content_root(highest_scoring)

      content_root
    end

    # Recursively process an element's children and remove any that are "empty"
    def clean_node(node, within_article: false)
      # Iterate over a copy of the children to avoid modification issues
      node.children.to_a.each do |child|
        if child.element?
          clean_node(child, within_article: within_article || node.name.downcase == "article" )  # process children first
          # Remove the child if it qualifies as "empty"

          if child.name.downcase == "aside" && !within_article
            child.remove
          elsif removable?(child)
            child.remove
          else
            child.remove_attribute("class") # Cleanup
          end
        end
      end
    end

    # An element is removable if:
    # - It is a <script> or <style> tag (non-visible content), or other element we don't want
    # - It has no descendant text nodes (ignoring whitespace)
    def removable?(node)
      # Remove button elements with Share or Save aria-labels
      if node.name.downcase == "button"
        aria_label = node['aria-label'].to_s.downcase
        return true if ["share", "save"].include?(aria_label)
      end

      # Remove nav with role=navigation
      if node.name.downcase == "nav"
        return true if node['role'].to_s.downcase == "navigation"
      end

      # Elements we don't care about
      return true if %w(link iframe script style footer nav form select textarea).include?(node.name.downcase)

      # Get rid of elements with classnames that look suspect
      class_list = node['class'].to_s.downcase.split(" ")
      return true if class_list.any?{ %w(comments-show comments actionbar related-stories navigation nodisplay sidebar admz hidden header footer social share).include?(_1) }

      id_list = node['id'].to_s.downcase.split(" ")
      return true if id_list.any?{ %w(header navigation ad admz sidebar related-stories hidden).include?(_1) }

      # Get rid of elements with inline styles that look suspect
      style_list = node['style'].to_s.downcase.split(";")
      return true if style_list.any?{ ["display: none", "display:none"].include?(_1) }

      # Don't remove images, etc in this step, which never have text content:
      return false if %w(img picture figure).include?(node.name.downcase)

      # Don't remove if any descendants are imgs, etc:
      return false if node.xpath(".//img | .//picture | .//figure").any?

      # Using XPath to find any descendant text node that contains non-whitespace characters.
      node.xpath(".//text()[normalize-space()]").empty?
    end

  end
end
