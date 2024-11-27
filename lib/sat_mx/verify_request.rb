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
        }.merge(HEADERS)
      ).body(Signer.sign(document: xml_document, private_key:))

      Result.new(success?: true, value: :accepted, xml: Nokogiri::XML(""))
    end

    private

    attr_reader :access_token, :private_key, :body

    def xml_document
      body.generate
    end
  end
end
