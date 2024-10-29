# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)
RSPEC_ROOT = File.dirname __FILE__

require "sat_mx"
require "debug"
require "webmock/rspec"
require "timecop"
require "support/matchers"
require "support/fixture_helper"
require "support/network_stubs"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.filter_run_when_matching :focus
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
