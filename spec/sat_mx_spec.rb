RSpec.describe SatMx do
  before do
    SatMx.configure do |config|
      config[:certificate] = "spec/fixtures/local_business/2526_mifiel_local_business.cer"
      config[:private_key] = "spec/fixtures/local_business/2526_mifiel_local_business.key"
      config[:password] = "12345678a"
    end
  end

  it "has a version number" do
    expect(SatMx::VERSION).not_to be nil
  end

  describe ".authenticate" do
    let(:success_response) do
      Nokogiri::XML::Document.parse(fixture("authentication/success_response.xml"))
    end

    it "authenticates" do
      stub_request(:post, "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/Autenticacion/Autenticacion.svc")
        .to_return(
          status: 200,
          body: fixture("authentication/success_response.xml"),
          headers: {"Content-Type" => "text/xml; charset=utf-8"}
        )

      result = SatMx.authenticate
      expect(result.success?).to be true
      expect(result.value).to eq("TOKEN")
    end

    it "accepts certificate and private_key" do
      stub_request(:post, "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/Autenticacion/Autenticacion.svc")
        .to_return(
          status: 200,
          body: fixture("authentication/success_response.xml"),
          headers: {"Content-Type" => "text/xml; charset=utf-8"}
        )

      result = SatMx.authenticate(
        certificate: OpenSSL::X509::Certificate.new(fixture("local_business/2526_mifiel_local_business.cer")),
        private_key: OpenSSL::PKey::RSA.new(fixture("local_business/2526_mifiel_local_business.key"), "12345678a")
      )
      expect(result.success?).to be true
      expect(result.value).to eq("TOKEN")
    end
  end

  describe ".download_request" do
    let(:access_token) { "FAKE_ACCESS_TOKEN" }
    let(:start_date) { Time.new(2024, 10, 1) }
    let(:end_date) { Time.new(2024, 10, 21) }
    let(:issuing_rfc) { "MOCR690424NZ5" }
    let(:recipient_rfcs) { ["AAA010101AAA"] }
    let(:requester_rfc) { "AAA010101AAA" }

    it "returns a successful result" do
      stub_download_request_success

      result = SatMx.download_request(
        start_date:,
        end_date:,
        request_type: :cfdi,
        issuing_rfc:,
        recipient_rfcs:,
        requester_rfc:,
        access_token:
      )

      expect(result.success?).to be true
      expect(result.value).to eq("43a72695-6684-4ca9-9cb5-62361528c354")
    end

    it "returns failure when CodEstatus is not 5000" do
      stub_download_request_failure_codestatus_300

      result = SatMx.download_request(
        start_date:,
        end_date:,
        request_type: :cfdi,
        issuing_rfc:,
        recipient_rfcs:,
        requester_rfc:,
        access_token:
      )

      expect(result.success?).to be false
      expect(result.value).to eq({
        cod_estatus: "300",
        mensaje: "Token invalido."
      })
    end

    it "accepts certificate and private_key options" do
      stub_download_request_success

      result = SatMx.download_request(
        start_date:,
        end_date:,
        request_type: :cfdi,
        issuing_rfc:,
        recipient_rfcs:,
        requester_rfc:,
        access_token:,
        certificate: OpenSSL::X509::Certificate.new(fixture("local_business/2526_mifiel_local_business.cer")),
        private_key: OpenSSL::PKey::RSA.new(fixture("local_business/2526_mifiel_local_business.key"), "12345678a")
      )

      expect(result.success?).to be true
    end
  end

  describe ".verify_request" do
    let(:request_id) { "606c5667-345a-4630-8979-0769734ac80b" }
    let(:requester_rfc) { "AAA010101AAA" }
    let(:access_token) { "FAKE_ACCESS_TOKEN" }

    it "returns a successful result with status accepted" do
      stub_verify_request_success(access_token:, body: fixture("verify_request/response_body.xml"))

      result = SatMx.verify_request(
        request_id:,
        requester_rfc:,
        access_token:
      )

      expect(result.success?).to be true
      expect(result.value).to eq({
        request_status: :accepted,
        package_ids: []
      })
    end

    it "returns package ids when status is finished" do
      stub_verify_request_success(access_token:, body: fixture("verify_request/response_with_packages_ids.xml"))

      result = SatMx.verify_request(
        request_id:,
        requester_rfc:,
        access_token:
      )

      expect(result.success?).to be true
      expect(result.value).to eq({
        request_status: :finished,
        package_ids: %w[4e80345d-917f-40bb-a98f-4a73939343c5_01 4e80345d-917f-40bb-a98f-4a73939343c5_02]
      })
    end

    it "accepts certificate and private_key options" do
      stub_verify_request_success(access_token:, body: fixture("verify_request/response_body.xml"))

      result = SatMx.verify_request(
        request_id:,
        requester_rfc:,
        access_token:,
        certificate: OpenSSL::X509::Certificate.new(fixture("local_business/2526_mifiel_local_business.cer")),
        private_key: OpenSSL::PKey::RSA.new(fixture("local_business/2526_mifiel_local_business.key"), "12345678a")
      )

      expect(result.success?).to be true
    end
  end

  describe ".download_petition" do
    let(:package_id) { "18015570-C084-4BE8-BE36-476F5D46A133_01" }
    let(:requester_rfc) { "AAA010101AAA" }
    let(:access_token) { "FAKE_ACCESS_TOKEN" }

    it "returns a successful result with decoded zip content" do
      stub_download_petition_success(access_token:)

      result = SatMx.download_petition(
        package_id:,
        requester_rfc:,
        access_token:
      )

      expect(result.success?).to be true
      expect(result.value).to eq("this is supposedly a base64 encoded zip file")
    end

    it "returns failure when CodEstatus is not 5000" do
      stub_download_petition_failure(access_token:)

      result = SatMx.download_petition(
        package_id:,
        requester_rfc:,
        access_token:
      )

      expect(result.success?).to be false
      expect(result.value).to eq({
        cod_estatus: "300",
        mensaje: "Token invalido."
      })
    end

    it "accepts certificate and private_key options" do
      stub_download_petition_success(access_token:)

      result = SatMx.download_petition(
        package_id:,
        requester_rfc:,
        access_token:,
        certificate: OpenSSL::X509::Certificate.new(fixture("local_business/2526_mifiel_local_business.cer")),
        private_key: OpenSSL::PKey::RSA.new(fixture("local_business/2526_mifiel_local_business.key"), "12345678a")
      )

      expect(result.success?).to be true
    end
  end

  describe ".download_request_received" do
    let(:access_token) { "FAKE_ACCESS_TOKEN" }
    let(:start_date) { Time.new(2024, 10, 1) }
    let(:end_date) { Time.new(2024, 10, 21) }
    let(:recipient_rfc) { "AAA010101AAA" }
    let(:requester_rfc) { "AAA010101AAA" }

    it "returns a successful result" do
      stub_download_request_received_success

      result = SatMx.download_request_received(
        start_date:,
        end_date:,
        request_type: :cfdi,
        recipient_rfc:,
        access_token:
      )

      expect(result.success?).to be true
      expect(result.value).to eq("a8129420-4f22-42b4-9a7f-0c193d89d09a")
    end

    it "returns failure when CodEstatus is not 5000" do
      stub_download_request_received_failure_codestatus_300

      result = SatMx.download_request_received(
        start_date:,
        end_date:,
        request_type: :cfdi,
        recipient_rfc:,
        access_token:
      )

      expect(result.success?).to be false
      expect(result.value).to eq({
        cod_estatus: "300",
        mensaje: "Usuario No Válido"
      })
    end

    it "accepts requester_rfc, issuing_rfc, and complement as keyword args" do
      stub_download_request_received_success

      result = SatMx.download_request_received(
        start_date:,
        end_date:,
        request_type: :cfdi,
        recipient_rfc:,
        requester_rfc:,
        issuing_rfc: "MOCR690424NZ5",
        complement: "nomina12",
        access_token:
      )

      expect(result.success?).to be true
    end

    it "accepts document_status as keyword arg" do
      stub_download_request_received_success

      result = SatMx.download_request_received(
        start_date:,
        end_date:,
        request_type: :cfdi,
        recipient_rfc:,
        document_status: "Cancelado",
        access_token:
      )

      expect(result.success?).to be true
    end

    it "accepts certificate and private_key options" do
      stub_download_request_received_success

      result = SatMx.download_request_received(
        start_date:,
        end_date:,
        request_type: :cfdi,
        recipient_rfc:,
        access_token:,
        certificate: OpenSSL::X509::Certificate.new(fixture("local_business/2526_mifiel_local_business.cer")),
        private_key: OpenSSL::PKey::RSA.new(fixture("local_business/2526_mifiel_local_business.key"), "12345678a")
      )

      expect(result.success?).to be true
    end
  end

  describe ".configuration" do
    it "configurates" do
      expect(SatMx.configuration.certificate).to eq(
        OpenSSL::X509::Certificate.new(
          fixture("local_business/2526_mifiel_local_business.cer")
        )
      )
      expect(SatMx.configuration.private_key.to_text).to eq(
        OpenSSL::PKey::RSA.new(
          fixture("local_business/2526_mifiel_local_business.key"),
          "12345678a"
        ).to_text
      )
    end
  end
end
