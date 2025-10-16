# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Readify is a Ruby gem that extracts essential content from HTML pages by removing navigation, ads, and other non-essential elements. It uses Nokogiri for HTML parsing and manipulation.

## Core Architecture

The gem has a simple architecture with two main components:

1. **Readify::Document** (`lib/readify/document.rb`) - The main class that processes HTML
   - Accepts raw HTML in the constructor
   - `readify!` method triggers content extraction
   - `extract_content` orchestrates the cleaning process
   - `remove_empty_nodes` strips the body of empty/non-visible elements
   - `clean_node` recursively processes DOM tree, removing unwanted nodes
   - `removable?` determines if a node should be removed based on:
     - Tag type (script, style, nav, footer, form, iframe, etc.)
     - CSS classes (comments, navigation, sidebar, hidden, etc.)
     - IDs (header, navigation, ad, sidebar, etc.)
     - Inline styles (display:none)
     - Empty content (no text or images)

2. **Module Structure**
   - `lib/readify.rb` - Main module file that requires dependencies
   - `lib/readify/version.rb` - Version constant
   - `lib/readify/document.rb` - Core content extraction logic

### Content Extraction Logic

The algorithm works by:
1. Parsing HTML with Nokogiri
2. Finding the `<body>` element
3. Recursively traversing child nodes
4. Removing nodes that are "empty" or unwanted based on heuristics
5. Preserving images and figures even if they contain no text
6. Tracking context (e.g., `within_article` flag) to handle elements differently based on location
7. Removing CSS classes from remaining elements to clean up output

Special handling:
- `<aside>` elements are removed unless they're within an `<article>`
- Images, pictures, and figures are always preserved
- Elements with descendant images are preserved

## Development Commands

**Install dependencies:**
```bash
bundle install
```

**Run tests:**
```bash
rake test
# or
bundle exec rake test
# or directly with tldr (the test framework)
rake tldr
```

**Run a single test file:**
```bash
ruby -I lib:test test/readify_test.rb
```

**Install gem locally for testing:**
```bash
bundle exec rake install
```

**Build gem:**
```bash
gem build readify.gemspec
```

**Release new version:**
1. Update version in `lib/readify/version.rb`
2. Run `bundle exec rake release`

## Testing

- Uses TLDR test framework (not Minitest or RSpec)
- Tests inherit from `TLDR` class
- Test files in `test/` directory
- Default rake task runs tests via `tldr/rake`

## Dependencies

**Runtime:**
- nokogiri ~> 1.15 - HTML/XML parsing

**Development:**
- tldr ~> 1.0 - Test framework
- rake ~> 13.0 - Build tool

## Ruby Version

Requires Ruby >= 2.7.0
