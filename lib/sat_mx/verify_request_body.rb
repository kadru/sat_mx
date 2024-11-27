require "base64"
require "sat_mx/body_constants"

module SatMx
  class VerifyRequestBody
    include BodySignature

    def initialize(certificate:, request_id:, requester_rfc:)
      @certificate = certificate
      @request_id = request_id
      @requester_rfc = requester_rfc
    end

    def generate
      Nokogiri::XML::Builder.new do |xml|
        xml[S11].Envelope(
          "#{XMLNS}:#{S11}" => "http://schemas.xmlsoap.org/soap/envelope/",
          "#{XMLNS}:des" => "http://DescargaMasivaTerceros.sat.gob.mx",
          "#{XMLNS}:ds" => "http://www.w3.org/2000/09/xmldsig#"
        ) do
          xml[S11].Header
          xml[S11].Body do
            xml[DES].VerificaSolicitudDescarga do
              xml[DES].solicitud(
                "IdSolicitud" => request_id,
                "RfcSolicitante" => requester_rfc
              ) do
                signature(xml)
              end
            end
          end
        end
      end.doc.root.to_xml
    end

    private

    attr_reader :certificate, :request_id, :requester_rfc
  end
end
