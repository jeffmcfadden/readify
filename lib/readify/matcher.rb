module Readify
  class Matcher

    # @param node [Nokogiri::XML::Node] The node to check for a match
    # @return [Boolean] true if the node matches the criteria, false otherwise
    def match?(node)
      raise NotImplementedError, "Subclasses must implement the match? method"
    end
  end
end