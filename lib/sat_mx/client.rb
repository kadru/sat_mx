require "httpx"

module SatMx
  class Client
    HEADERS = {
      "content-type" => "text/xml; charset=utf-8",
      "accept" => "text/xml"
    }.freeze
    private_constant :HEADERS

    def initialize(private_key:, access_token:)
      @private_key = private_key
      @access_token = access_token
    end

    def verify_request(payload)
      HTTPX.post(
        "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/VerificaSolicitudDescargaService.svc",
        headers: {
          "Authorization" => "WRAP access_token=\"#{access_token}\"",
          "SOAPAction" => "http://DescargaMasivaTerceros.sat.gob.mx/IVerificaSolicitudDescargaService/VerificaSolicitudDescarga"
        }.merge(HEADERS),
        body: Signer.sign(document: payload, private_key:)
      )
    end

    private

    attr_reader :private_key, :access_token
  end
end
