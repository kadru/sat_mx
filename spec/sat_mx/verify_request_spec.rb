require "nokogiri"

RSpec.describe SatMx::VerifyRequest do
  let(:request_id) { "606c5667-345a-4630-8979-0769734ac80b" }
  let(:requester_rfc) { "AAA010101AAA" }
  let(:access_token) { "eyJhbGciOiJodHRwOi8vd3d" }
  let(:certificate) do
    OpenSSL::X509::Certificate.new(
      fixture("local_business/2526_mifiel_local_business.cer")
    )
  end

  let(:private_key) do
    OpenSSL::PKey::RSA.new(
      fixture("local_business/2526_mifiel_local_business.key"),
      "12345678a"
    )
  end

  describe ".call" do
    it do
      stub_verify_request_success(access_token:, body: verify_request_response_body)

      result = described_class.call(request_id:, access_token:, requester_rfc:, private_key:, certificate:)

      expect(result).to be_success
      expect(result.value).to eq(:accepted)
      expect(result.xml).to be_same_xml(expected_body)
    end

    context "when EstadoSolicitud is terminada" do
      it "result value is finished" do
        stub_verify_request_success(access_token:, body: verify_request_response_body(status: "3"))

        result = described_class.call(request_id:, access_token:, requester_rfc:, private_key:, certificate:)

        expect(result).to be_success
        expect(result.value).to eq(:finished)
        expect(result.xml).to be_same_xml(expected_body(status: "3"))
      end
    end

    context "when request auth fails" do
      it do
        stub_verify_request_failure(access_token:)

        result = described_class.call(request_id:, access_token:, requester_rfc:, private_key:, certificate:)

        expect(result).not_to be_success
        expect(result.value).to be_nil
      end
    end
  end

  private

  def expected_body(status: "1")
    Nokogiri::XML(verify_request_response_body(status:))
  end

  def verify_request_response_body(status: "1")
    <<~XML
      <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
        <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:xsd="http://www.w3.org/2001/XMLSchema">
          <VerificaSolicitudDescargaResponse xmlns="http://DescargaMasivaTerceros.sat.gob.mx">
            <VerificaSolicitudDescargaResult CodEstatus="5000" EstadoSolicitud="#{status}" CodigoEstadoSolicitud="5000" NumeroCFDIs="0" Mensaje="Solicitud Aceptada"/>
          </VerificaSolicitudDescargaResponse>
        </s:Body>
      </s:Envelope>
    XML
  end
end
