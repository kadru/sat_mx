module FixtureHelper
  def fixture_path(filename)
    File.join(RSPEC_ROOT, "fixtures", filename)
  end

  def fixture(path)
    File.read fixture_path(path)
  end
end

RSpec.configure do |config|
  config.include FixtureHelper
end
