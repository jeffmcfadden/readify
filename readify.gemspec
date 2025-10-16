# frozen_string_literal: true

require_relative "lib/readify/version"

Gem::Specification.new do |spec|
  spec.name = "readify"
  spec.version = Readify::VERSION
  spec.authors = ["Jeff McFadden"]
  spec.email = ["jeff@example.com"]

  spec.summary = "Extract the essential content from HTML pages"
  spec.description = "Readify takes HTML pages and strips them down to only the essential nodes, making content easier to read and process."
  spec.homepage = "https://github.com/jeffmcfadden/readify"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[test/ spec/ features/ .git .circleci appveyor])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "nokogiri", "~> 1.15"
  spec.add_dependency "http", "~> 5.0"

  # Development dependencies
  spec.add_development_dependency "tldr", "~> 1.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
