require "nokogiri"

RSpec.describe SatMx::VerifyRequest do
  let(:request_id) { "606c5667-345a-4630-8979-0769734ac80b" }
  let(:requester_rfc) { "AAA010101AAA" }
  let(:access_token) { "eyJhbGciOiJodHRwOi8vd3d" }

  describe ".call" do
    it do
      result = described_class.call(request_id:, access_token:, requester_rfc:)

      expect(result).to be_success
      expect(result.value).to eq(:accepted)
      expect(result.xml).to be_same_xml(expected_body)
    end
  end

  private

  def expected_body
    Nokogiri::XML(
      <<~XML
        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
          <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <VerificaSolicitudDescargaResponse xmlns="http://DescargaMasivaTerceros.sat.gob.mx">
              <VerificaSolicitudDescargaResult CodEstatus="5000" EstadoSolicitud="1" CodigoEstadoSolicitud="5000" NumeroCFDIs="0" Mensaje="Solicitud Aceptada"/>
            </VerificaSolicitudDescargaResponse>
          </s:Body>
        </s:Envelope>
      XML
    )
  end
end
