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
