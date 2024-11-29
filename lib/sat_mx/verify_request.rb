require "httpx"

module SatMx
  class VerifyRequest
    URL = "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/VerificaSolicitudDescargaService.svc"
    HEADERS = {
      "content-type" => "text/xml; charset=utf-8",
      "accept" => "text/xml",
      "SOAPAction" => "http://DescargaMasivaTerceros.sat.gob.mx/IVerificaSolicitudDescargaService/VerificaSolicitudDescarga"
    }.freeze
    private_constant :URL
    private_constant :HEADERS

    STATUS = {
      "1" => :accepted,
      "2" => :in_proccess,
      "3" => :finished,
      "4" => :error,
      "5" => :rejected,
      "6" => :expired
    }

    def self.call(request_id:, requester_rfc:, access_token:, private_key:, certificate:)
      new(
        request_id:,
        requester_rfc:,
        access_token:,
        private_key:,
        body: VerifyRequestBody.new(request_id:, requester_rfc:, certificate:)
      ).call
    end

    def initialize(request_id:, requester_rfc:, access_token:, private_key:, body:)
      @request_id = request_id
      @requester_rfc = requester_rfc
      @access_token = access_token
      @private_key = private_key
      @body = body
    end

    def call
      response = HTTPX.post(
        URL,
        headers: {
          "Authorization" => "WRAP access_token=\"#{access_token}\""
        }.merge(HEADERS),
        body: Signer.sign(document: xml_document, private_key:)
      )

      case response.status
      when 200..299
        status = STATUS.fetch(
          response.xml.xpath(
            "//xmlns:VerificaSolicitudDescargaResult",
            xmlns: "http://DescargaMasivaTerceros.sat.gob.mx"
          )
          .attribute("EstadoSolicitud").value
        )
        Result.new(success?: true,
          value: status,
          xml: response.xml)
      when 400..599
        Result.new(success?: false, value: nil, xml: response.xml)
      else
        SatMx::Error
      end
    end

    private

    attr_reader :access_token, :private_key, :body

    def xml_document
      body.generate
    end
  end
end
