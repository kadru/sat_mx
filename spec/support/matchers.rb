# expects a Nokogiri::XML::Document
RSpec::Matchers.define :be_same_xml do |expected|
  match do |actual|
    actual.canonicalize == expected.canonicalize
  end
end
