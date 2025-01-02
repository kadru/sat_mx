# frozen_string_literal: true

RSpec.shared_context "certificate" do
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
end

RSpec.configure do |config|
  config.include_context "certificate", with_certificate: true
end
