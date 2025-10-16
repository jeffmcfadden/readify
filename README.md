# Readify

Readify is a Ruby gem that extracts the essential content from HTML pages, stripping away navigation, ads, and other non-essential elements to leave only the main readable content.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'readify'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install readify

## Usage

```ruby
require 'readify'

html = File.read('article.html')
doc = Readify::Document.new(html)
clean_html = doc.extract

puts clean_html
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jeffmcfadden/readify.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
