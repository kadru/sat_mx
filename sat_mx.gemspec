require_relative "lib/sat_mx/version"

Gem::Specification.new do |spec|
  spec.name = "sat_mx"
  spec.version = SatMx::VERSION
  spec.authors = ["Oscar Rivas"]
  spec.email = ["orivas155@gmail.com"]

  spec.summary = "a client to connect to SAT web services"
  spec.description = "connect to SAT web services in a simple and productive way"
  spec.homepage = "https://github.com/kadru/sat_mx"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/kadru/sat_mx/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "xmldsig", "< 1.0"
  spec.add_dependency "httpx", "~> 1.3"
  spec.add_dependency "base64", "< 1"
  spec.add_development_dependency "standard", "~> 1.4"
  spec.add_development_dependency "debug", "~> 1.9"
  spec.add_development_dependency "webmock", "~> 3.24"
  spec.add_development_dependency "timecop", "~> 0.9"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
