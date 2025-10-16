module Readify
  class DocumentFetcher

    def initialize
    end

    def fetch(url)
      HTTP.timeout(9).headers(headers).get(url).to_s
    end

    private

    def headers
      {
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language" => "en-US,en;q=0.9",
        "User-Agent" => safari_ua,
      }
    end

    def safari_ua
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3.1 Safari/605.1.15"
    end

    def googlebot_ua
      "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Chrome/134.0.6998.130 Safari/537.36"
    end

  end
end