# frozen_string_literal: true

require_relative "lib/iodine_cable/version"

Gem::Specification.new do |spec|
  spec.name = "iodine_cable"
  spec.version = IodineCable::VERSION
  spec.authors = ["Anton Yordanov"]
  spec.email = ["anton.yordanov@gmail.com"]

  spec.summary = "A WebSocket library using the Iodine Web Server for Ruby projects."
  spec.description = "IodineCable provides an easy-to-use WebSocket library using the Iodine Web Server for Ruby projects, with optional Rails integration through a separate gem."
  spec.homepage = "https://github.com/anton-yordanov/iodine_cable"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/anton-yordanov/iodine_cable"
  spec.metadata["changelog_uri"] = "https://github.com/anton-yordanov/iodine_cable/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "iodine", "<0.8"
  spec.add_dependency "rack", "~> 3.0"
  spec.add_dependency "redis", "~> 5.0"
  spec.add_dependency "hiredis-client", "~> 0.14"
  spec.add_dependency "connection_pool", "~> 2.4"
end
