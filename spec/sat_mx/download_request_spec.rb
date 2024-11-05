RSpec.describe SatMx::DownloadRequest do
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
    let(:access_token) { "FAKE_ACCESS_TOKEN" }
    let(:start_date) { Time.new(2024, 10, 1) }
    let(:end_date) { Time.new(2024, 10, 21) }
    let(:issuing_rfc) { "MOCR690424NZ5" }
    let(:recipient_rfcs) { ["AAA010101AAA"] }
    let(:requester_rfc) { "AAA010101AAA" }

    it "returns a a successful result" do
      stub_download_request_success

      result = described_class.call(
        access_token:,
        certificate:,
        private_key:,
        start_date:,
        end_date:,
        request_type: :cfdi,
        issuing_rfc:,
        recipient_rfcs:,
        requester_rfc:
      )

      expect(result).to be_success
      expect(result.value).to eq("43a72695-6684-4ca9-9cb5-62361528c354")
      expect(result.xml).to be_same_xml(expected_body)
    end

    context "when request fails" do
      it "returns a unsuccesful result" do
        stub_download_request_failure

        result = described_class.call(
          access_token:,
          certificate:,
          private_key:,
          start_date:,
          end_date:,
          request_type: :cfdi,
          issuing_rfc:,
          recipient_rfcs:,
          requester_rfc:
        )

        expect(result).not_to be_success
      end
    end
  end

  def expected_body
    Nokogiri::XML::Document.parse(fixture("download_request/response.xml"))
  end
end
