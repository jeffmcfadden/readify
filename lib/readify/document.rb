module Readify
  class Document
    attr_reader :html, :cleaned

    def initialize(html)
      @html = html
      @cleaned = nil
      self
    end

    def cleaned?
      @cleaned != nil
    end

    def cleaned
      @cleaned
    end

    def readify!
      @cleaned ||= DocumentCleaner.new.clean(@html)
    end

  end
end