# frozen_string_literal: true

RSpec.describe SatMx::DownloadPetition, :with_certificate do
  describe ".call" do
    let(:package_ids) { ["18015570-C084-4BE8-BE36-476F5D46A133_01"] }
    let(:requester_rfc) { "AAA010101AAA" }
    let(:access_token) { "FAKE_ACCESS_TOKEN" }

    it do
      result = described_class.call(
        package_ids: package_ids,
        requester_rfc: requester_rfc,
        access_token: access_token,
        certificate: certificate,
        private_key: private_key
      )

      expect(result).to be_success
    end
  end
end
