require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[spec standard]

namespace :gem do
  desc "Release gem (Usage: rake gem:release[patch|minor|major])"
  task :release, [:bump_type] do |_t, args|
    bump_type = args[:bump_type] || raise("Please specify bump type: patch, minor, or major")

    sh "gem bump --version #{bump_type} --no-commit"
    sh "bundle install"

    version = File.read("lib/sat_mx/version.rb")[/>= (.+)/, 1]
    sh "git add Gemfile.lock"
    sh "git add lib/sat_mx/version.rb"
    sh "git commit -m \"Bump sat_mx to #{version}\""
    sh "git push origin main"
    sh "gem release --tag --push"
  end
end
