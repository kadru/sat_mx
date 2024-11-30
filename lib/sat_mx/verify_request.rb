require "httpx"

module SatMx
  class VerifyRequest
    STATUS = {
      "1" => :accepted,
      "2" => :in_proccess,
      "3" => :finished,
      "4" => :error,
      "5" => :rejected,
      "6" => :expired
    }
    private_constant :STATUS

    def self.call(request_id:, requester_rfc:, access_token:, private_key:, certificate:)
      new(
        body: VerifyRequestBody.new(request_id:, requester_rfc:, certificate:),
        client: Client.new(private_key:, access_token:)
      ).call
    end

    def initialize(body:, client:)
      @body = body
      @client = client
    end

    def call
      response = client.verify_request(body.generate)
      case response.status
      when 200..299
        Result.new(success?: true,
          value: value(response.xml),
          xml: response.xml)
      when 400..599
        Result.new(success?: false, value: nil, xml: response.xml)
      else
        SatMx::Error
      end
    end

    private

    attr_reader :body, :client

    def value(xml)
      {
        request_status: STATUS.fetch(
          xml.xpath(
            "//xmlns:VerificaSolicitudDescargaResult",
            xmlns: "http://DescargaMasivaTerceros.sat.gob.mx"
          )
          .attribute("EstadoSolicitud").value
        ),
        package_ids: xml.xpath("//xmlns:IdsPaquetes", xmlns: "http://DescargaMasivaTerceros.sat.gob.mx").map(&:inner_text)
      }
    end
  end
end
