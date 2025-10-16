# frozen_string_literal: true

require "test_helper"

class ReadifyTest < TLDR
  def test_that_it_has_a_version_number
    refute_nil ::Readify::VERSION
  end

  def test_document_initialization
    html = "<html><body><p>Test content</p></body></html>"
    doc = Readify::Document.new(html)
    assert_instance_of Readify::Document, doc
  end
end
