RSpec.describe SatMx::DownloadPetition, :with_certificate do
  describe ".call" do
    let(:package_id) { "18015570-C084-4BE8-BE36-476F5D46A133_01" }
    let(:requester_rfc) { "AAA010101AAA" }
    let(:access_token) { "FAKE_ACCESS_TOKEN" }

    it "returns a successful result" do
      stub_download_petition_success(access_token:)

      result = described_class.call(
        package_id: package_id,
        requester_rfc: requester_rfc,
        access_token: access_token,
        certificate: certificate,
        private_key: private_key
      )

      expect(result).to be_success
      expect(result.xml).to be_same_xml(expected_xml)
      expect(result.value).to eq(base64_content)
    end

    context "when request fails with invalid CodEstatus" do
      it "returns a unsuccesful result" do
        stub_download_petition_failure(access_token:)

        result = described_class.call(
          package_id: package_id,
          requester_rfc: requester_rfc,
          access_token: access_token,
          certificate: certificate,
          private_key: private_key
        )

        expect(result).not_to be_success
        expect(result.value).to eq({
          CodEstatus: "300",
          Mensaje: "Token invalido."
        })
      end
    end

    context "when request fails with invalid http status" do
      it "returns a unsuccesful result" do
        stub_download_petition(access_token:).to_return(status: 500)

        result = described_class.call(
          package_id: package_id,
          requester_rfc: requester_rfc,
          access_token: access_token,
          certificate: certificate,
          private_key: private_key
        )

        expect(result).not_to be_success
      end
    end

    private

    def base64_content
      "dGhpcyBpcyBzdXBwb3NlZGx5IGEgYmFzZTY0IGVuY29kZWQgemlwIGZpbGU="
    end

    def expected_xml
      Nokogiri::XML::Document.parse(
        <<~XML
          <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
            <s:Header>
              <h:respuesta CodEstatus="5000" Mensaje="Solicitud Aceptada"
                xmlns:h="http://DescargaMasivaTerceros.sat.gob.mx"
                xmlns="http://DescargaMasivaTerceros.sat.gob.mx"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
            </s:Header>
            <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xmlns:xsd="http://www.w3.org/2001/XMLSchema">
              <RespuestaDescargaMasivaTercerosSalida xmlns="http://DescargaMasivaTerceros.sat.gob.mx">
                <Paquete>dGhpcyBpcyBzdXBwb3NlZGx5IGEgYmFzZTY0IGVuY29kZWQgemlwIGZpbGU=</Paquete>
              </RespuestaDescargaMasivaTercerosSalida>
            </s:Body>
          </s:Envelope>
        XML
      )
    end
  end
end
