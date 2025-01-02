module SatMx
  module Body
    def envelope
      Nokogiri::XML::Builder.new do |xml|
        xml[S11].Envelope(
          ENVELOPE_ATTRS
        ) do
          xml[S11].Header
          xml[S11].Body do
            yield xml
          end
        end
      end.doc.root.to_xml
    end
  end
end
