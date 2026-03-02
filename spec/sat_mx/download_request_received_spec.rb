RSpec.describe SatMx::DownloadRequestReceived, :with_certificate do
  describe ".call" do
    let(:access_token) { "FAKE_ACCESS_TOKEN" }
    let(:start_date) { Time.new(2024, 10, 1) }
    let(:end_date) { Time.new(2024, 10, 21) }
    let(:recipient_rfc) { "AAA010101AAA" }
    let(:requester_rfc) { "AAA010101AAA" }

    it "returns a successful result" do
      stub_download_request_received_success

      result = described_class.call(
        access_token:,
        certificate:,
        private_key:,
        start_date:,
        end_date:,
        request_type: :cfdi,
        recipient_rfc:,
        requester_rfc:
      )

      expect(result).to be_success
      expect(result.value).to eq("a8129420-4f22-42b4-9a7f-0c193d89d09a")
    end

    context "when response has an unsuccesful CodEstatus" do
      it "returns an unsuccesful result" do
        stub_download_request_received_failure_codestatus_300

        result = described_class.call(
          access_token:,
          certificate:,
          private_key:,
          start_date:,
          end_date:,
          request_type: :cfdi,
          recipient_rfc:,
          requester_rfc:
        )

        expect(result).not_to be_success
        expect(result.value).to eq({
          cod_estatus: "300",
          mensaje: "Usuario No Válido"
        })
      end
    end

    context "when request fails" do
      it "returns an unsuccesful result" do
        stub_download_request_received_failure

        result = described_class.call(
          access_token:,
          certificate:,
          private_key:,
          start_date:,
          end_date:,
          request_type: :cfdi,
          recipient_rfc:,
          requester_rfc:
        )

        expect(result).not_to be_success
      end
    end

    context "with optional parameters" do
      let(:issuing_rfc) { "MOCR690424NZ5" }

      it "includes issuing_rfc when provided" do
        stub_download_request_received_success

        result = described_class.call(
          access_token:,
          certificate:,
          private_key:,
          start_date:,
          end_date:,
          request_type: :cfdi,
          recipient_rfc:,
          requester_rfc:,
          issuing_rfc:
        )

        expect(result).to be_success
      end
    end

    context "with invalid complement" do
      it "returns an unsuccessful result" do
        result = described_class.call(
          access_token:,
          certificate:,
          private_key:,
          start_date:,
          end_date:,
          request_type: :cfdi,
          recipient_rfc:,
          requester_rfc:,
          complement: "invalid_type"
        )

        expect(result).not_to be_success
        expect(result.value).to eq({
          cod_estatus: "INVALID_COMPLEMENT",
          mensaje: "Invalid complement type: invalid_type"
        })
      end
    end

    context "with invalid document_status" do
      it "returns an unsuccessful result" do
        result = described_class.call(
          access_token:,
          certificate:,
          private_key:,
          start_date:,
          end_date:,
          request_type: :cfdi,
          recipient_rfc:,
          requester_rfc:,
          document_status: "invalid_status"
        )

        expect(result).not_to be_success
        expect(result.value).to eq({
          cod_estatus: "INVALID_DOCUMENT_STATUS",
          mensaje: "Invalid document status: invalid_status"
        })
      end
    end
  end
end
