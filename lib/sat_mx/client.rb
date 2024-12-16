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

    def authenticate(payload)
      HTTPX.post(
        "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/Autenticacion/Autenticacion.svc",
        headers: {
          "SOAPAction" => "http://DescargaMasivaTerceros.gob.mx/IAutenticacion/Autentica"
        }.merge(HEADERS),
        body: sign(payload)
      )
    end

    def download_request(payload)
      HTTPX.post(
        "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/SolicitaDescargaService.svc",
        headers: {
          "SOAPAction" => "http://DescargaMasivaTerceros.sat.gob.mx/ISolicitaDescargaService/SolicitaDescarga"
        }.merge(authorization)
        .merge(HEADERS),
        body: sign(payload)
      )
    end

    def verify_request(payload)
      HTTPX.post(
        "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/VerificaSolicitudDescargaService.svc",
        headers: {
          "SOAPAction" => "http://DescargaMasivaTerceros.sat.gob.mx/IVerificaSolicitudDescargaService/VerificaSolicitudDescarga"
        }.merge(authorization)
        .merge(HEADERS),
        body: sign(payload)
      )
    end

    private

    attr_reader :private_key, :access_token

    def authorization
      {"Authorization" => "WRAP access_token=\"#{access_token}\""}
    end

    def sign(payload)
      Signer.sign(document: payload, private_key:)
    end
  end
end
