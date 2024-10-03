# expects a Nokogiri::XML::Document
RSpec::Matchers.define :be_same_xml do |xml_doc|
  match do |xml_to_match|
    xml_to_match.canonicalize == xml_doc.canonicalize
  end
end
