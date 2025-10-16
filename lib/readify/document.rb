module Readify
  class Document
    attr_reader :html, :readified

    def initialize(html)
      @html = html
      @readified = nil
      self
    end

    def cleaned
      @readified
    end

    def readify!
      @readified ||= extract_content
    end

    def extract_content
      remove_empty_nodes(@html)
    end

    # Returns the full HTML with empty (non-visible) elements removed from <body>
    def remove_empty_nodes(html)
      doc = Nokogiri::HTML(html)
      body = doc.at('body')
      clean_node(body) if body
      body
    end

    # Recursively process an element’s children and remove any that are "empty"
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