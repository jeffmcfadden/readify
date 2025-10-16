require "test_helper"

class BasicTest < TLDR
  def test_that_we_can_parse_basic_html
    doc = Readify::Document.new(File.open("test/sample_documents/basic.html").read)
    doc.readify!
  end
end
