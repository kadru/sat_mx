require "httpx"
require "xmldsig"
require "sat_mx/download_request_body"

module SatMx
  class DownloadRequest
    URL = "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/SolicitaDescargaService.svc"
    HEADERS = {
      "Content-type" => "text/xml; charset=utf-8",
      "Accept" => "text/xml",
      "SOAPAction" => "http://DescargaMasivaTerceros.sat.gob.mx/ISolicitaDescargaService/SolicitaDescarga"
    }.freeze

    private_constant :URL
    private_constant :HEADERS

    def self.call(start_date:,
      end_date:,
      request_type:,
      issuing_rfc:,
      recipient_rfcs:,
      requester_rfc:,
      access_token:,
      certificate:,
      private_key:)
      new(
        download_request_body: DownloadRequestBody.new(
          start_date:,
          end_date:,
          request_type:,
          issuing_rfc:,
          recipient_rfcs:,
          requester_rfc:,
          certificate:
        ),
        private_key: private_key,
        access_token: access_token
      ).call
    end

    def initialize(download_request_body:, private_key:, access_token:)
      @download_request_body = download_request_body
      @private_key = private_key
      @access_token = access_token
    end

    def call
      response = HTTPX.post(
        URL,
        headers: {
          "Authorization" => "WRAP access_token=\"#{access_token}\""
        }.merge(HEADERS),
        body: Xmldsig::SignedDocument.new(xml_document).sign do |data|
          private_key.sign(OpenSSL::Digest.new("SHA1"), data)
        end
      )

      case response.status
      when 200..299
        Result.new(success?: true,
          value: response.xml.xpath("//xmlns:SolicitaDescargaResult",
            xmlns: "http://DescargaMasivaTerceros.sat.gob.mx").attribute("IdSolicitud").value,
          xml: response.xml)
      when 400..599
        Result.new(success?: false, value: nil, xml: response.xml)
      else
        SatMx::Error
      end
    end

    private

    attr_reader :download_request_body, :private_key, :access_token

    def xml_document
      download_request_body.generate
    end
  end
end
