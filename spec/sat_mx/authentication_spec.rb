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
        uuid: "17368d82-4a74-4bc2-8ed1-3e9e490e5433"
      )

      expect(result).to be_success
      expect(result.value).to eq("eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE3Mjc3MzczMTAsImV4cCI6MTcyNzczNzkxMCwiaWF0IjoxNzI3NzM3MzEwLCJpc3MiOiJMb2FkU29saWNpdHVkRGVjYXJnYU1hc2l2YVRlcmNlcm9zIiwiYWN0b3J0IjoiMzAzMDMwMzAzMTMwMzAzMDMwMzAzMDM3MzAzMDMzMzkzMjMwMzgzOSJ9.wOLFgZBRCIy09aKJZD2hiAUt_TjPwHYCIDQCVzKP_78%26wrap_subject%3d3030303031303030303030373030333932303839")
      expect(result.xml).to be_same_xml(success_response)
    end

    context "when authentication fails" do
      it "returns a unsuccessful result" do
        stub_authentication_failure

        result = SatMx::Authentication.authenticate(
          certificate:,
          private_key:,

          uuid: "17368d82-4a74-4bc2-8ed1-3e9e490e5433"
        )

        expect(result).not_to be_success
        expect(result.xml).to be_same_xml(failure_auth_response)
      end
    end
  end
end
