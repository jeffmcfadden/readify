require "nokogiri"

require_relative "readify/matchers/obvious_junk_matcher"
require_relative "readify/matchers/removable_node_matcher"
require_relative "readify/node_scorer"
require_relative "readify/document"
require_relative "readify/document_cleaner"
require_relative "readify/document_fetcher"
require_relative "readify/version"

module Readify
  class Error < StandardError; end
end
