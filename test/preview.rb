#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "http"
require_relative "../lib/readify"

# Get URL from command line or use default
url = ARGV[0] || "https://example.com"

# Ensure tmp directory exists
Dir.mkdir("tmp") unless Dir.exist?("tmp")

# Output file path
output_file = File.expand_path("../tmp/preview.html", __dir__)

def fetch_and_readify(url, output_file)
  puts "Fetching: #{url}"

  # Fetch the URL
  html = Readify::DocumentFetcher.new.fetch(url)

  puts "Readifying content..."

  # Readify the content
  doc = Readify::Document.new(html)
  doc.readify!
  clean_html = doc.cleaned

  # Write to file
  File.write(output_file, clean_html.to_html)

  puts "Saved to: #{output_file}"
  puts "Opening in browser..."

  # Open in default browser
  system("open", output_file)
end

# Initial run
fetch_and_readify(url, output_file)

# Loop for quick iteration
loop do
  puts "\nPress Enter to reload and re-process (Ctrl+C to quit)..."
  STDIN.gets.chomp

  puts "\nReloading source files..."

  # Reload all Readify source files
  load File.expand_path("../lib/readify/version.rb", __dir__)
  load File.expand_path("../lib/readify/document.rb", __dir__)
  load File.expand_path("../lib/readify/document_fetcher.rb", __dir__)
  load File.expand_path("../lib/readify.rb", __dir__)

  puts "Source files reloaded!"

  # Re-run the fetch and readify
  fetch_and_readify(url, output_file)
end
