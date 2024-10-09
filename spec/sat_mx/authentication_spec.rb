require "spec_helper"

RSpec.describe SatMx::Authentication do
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

  let(:success_response) do
    Nokogiri::XML::Document.parse(fixture("authentication/success_response.xml"))
  end

  let(:failure_auth_response) do
    Nokogiri::XML::Document.parse(fixture("authentication/failure_auth_response.xml"))
  end

  describe ".authenticate" do
    around do |example|
      Timecop.freeze(Time.new(2024, 10, 1)) do
        example.run
      end
    end

    it "returns the authenticate response" do
      stub_authentication_success
      result = SatMx::Authentication.authenticate(
        certificate:,
        private_key:,
        id: "uuid-17368d82-4a74-4bc2-8ed1-3e9e490e5433-1"
      )

      expect(result).to be_success
      expect(result.value).to be_same_xml(success_response)
    end

    context "when authentication fails" do
      it "returns a unsuccessful result" do
        stub_authentication_failure

        result = SatMx::Authentication.authenticate(
          certificate:,
          private_key:,
          id: "uuid-17368d82-4a74-4bc2-8ed1-3e9e490e5433-1"
        )

        expect(result).not_to be_success
        expect(result.value).to be_same_xml(failure_auth_response)
      end
    end
  end

  private

  def stub_authentication_success
    stub_auth_service
      .to_return(
        status: 200,
        headers: {
          "content-type" => "text/xml; charset=utf-8",
          "content-encoding" => "gzip",
          "vary" => "Accept-Encoding",
          "server" => "Microsoft-IIS/10.0",
          "x-content-type-options" => "nosniff",
          "x-xss-protection" => "1",
          "strict-transport-security" => "max-age=31536000; includeSubDomains",
          "x-frame-options" => "SAMEORIGIN",
          "date" => "Mon, 30 Sep 2024 20:30:10 GMT"
        },
        body: fixture("authentication/success_response.xml")
      )
  end

  def stub_authentication_failure
    stub_auth_service
      .to_return(
        status: 500,
        headers: {
          "content-type" => "text/xml; charset=utf-8",
          "server" => "Microsoft-IIS/10.0",
          "x-content-type-options" => "nosniff",
          "x-xss-protection" => "1",
          "strict-transport-security" => "max-age=31536000; includeSubDomains",
          "x-frame-options" => "SAMEORIGIN",
          "date" => "Thu, 03 Oct 2024 19:50:16 GMT",
          "content-length" => "347"
        },
        body: fixture("authentication/failure_auth_response.xml")
      )
  end

  def stub_auth_service
    stub_request(
      :post,
      "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/Autenticacion/Autenticacion.svc"
    ).with(
      headers: {
        "Accept" => "text/xml",
        "Accept-Encoding" => "gzip, deflate",
        "Content-Type" => "text/xml; charset=utf-8",
        "Soapaction" => "http://DescargaMasivaTerceros.gob.mx/IAutenticacion/Autentica"
      },
      body: Nokogiri::XML(
        fixture("authentication/auth_request.xml"),
        nil,
        nil,
        Nokogiri::XML::ParseOptions::STRICT
      ).to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
    )
  end
end
