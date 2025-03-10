module SatMx
  Configuration = Data.define(:certificate, :private_key) do
    def initialize(certificate:, private_key:, password:)
      super(
        certificate: OpenSSL::X509::Certificate.new(File.read(certificate)),
        private_key: OpenSSL::PKey::RSA.new(
          File.read(private_key),
          password
        )
      )
    end
  end
end
