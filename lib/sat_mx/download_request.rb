require "httpx"
require "xmldsig"

module SatMx
  class DownloadRequest
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
        client: Client.new(private_key:, access_token:)
      ).call
    end

    def initialize(download_request_body:, client:)
      @download_request_body = download_request_body
      @client = client
    end

    def call
      response = client.download_request(download_request_body.generate)

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

    attr_reader :download_request_body, :client
  end
end
