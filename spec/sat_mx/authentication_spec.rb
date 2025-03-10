require "spec_helper"

RSpec.describe SatMx::Authentication, :with_certificate do
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
      expect(result.value).to eq("TOKEN")
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
