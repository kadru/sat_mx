require "nokogiri"

RSpec.describe SatMx::VerifyRequest, :with_certificate do
  let(:request_id) { "606c5667-345a-4630-8979-0769734ac80b" }
  let(:requester_rfc) { "AAA010101AAA" }
  let(:access_token) { "eyJhbGciOiJodHRwOi8vd3d" }

  describe ".call" do
    let(:verify_request_response_body) do
      fixture("verify_request/response_body.xml")
    end

    it do
      stub_verify_request_success(access_token:, body: verify_request_response_body)

      result = described_class.call(request_id:, access_token:, requester_rfc:, private_key:, certificate:)

      expect(result).to be_success
      expect(result.value).to eq({
        request_status: :accepted,
        package_ids: []
      })
      expect(result.xml).to be_same_xml(parse_xml(verify_request_response_body))
    end

    context "when EstadoSolicitud is terminada" do
      let(:verify_request_response_with_packages_ids) do
        fixture("verify_request/response_with_packages_ids.xml")
      end

      it "result value is finished" do
        stub_verify_request_success(access_token:, body: verify_request_response_with_packages_ids)

        result = described_class.call(request_id:, access_token:, requester_rfc:, private_key:, certificate:)

        expect(result).to be_success
        expect(result.value).to eq({
          request_status: :finished,
          package_ids: %w[4e80345d-917f-40bb-a98f-4a73939343c5_01 4e80345d-917f-40bb-a98f-4a73939343c5_02]
        })
        expect(result.xml).to be_same_xml(parse_xml(verify_request_response_with_packages_ids))
      end
    end

    context "when CodigoEstadoSolicitud is not 5000" do
      let(:verify_request_invalid_codEstatus) do
        fixture("verify_request/response_invalid_codEstatus.xml")
      end

      it "fails" do
        stub_verify_request_success(access_token:, body: verify_request_invalid_codEstatus)
        result = described_class.call(request_id:, access_token:, requester_rfc:, private_key:, certificate:)

        expect(result).not_to be_success
        expect(result.value).to be_eql({
          CodEstatus: "300",
          Mensaje: "Token invalido."
        })
        expect(result.xml).to be_same_xml(parse_xml(verify_request_invalid_codEstatus))
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

  def parse_xml(xml)
    Nokogiri::XML(xml)
  end
end
