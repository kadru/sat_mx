module SatMx
  class Signer
    def self.sign(document:, private_key:)
      new(document:, private_key:).sign
    end

    def initialize(document:, private_key:)
      @unsigned_document = Xmldsig::SignedDocument.new(document)
      @private_key = private_key
    end

    def sign
      unsigned_document.sign do |data|
        private_key.sign(OpenSSL::Digest.new("SHA1"), data)
      end
    end

    private

    attr_reader :unsigned_document, :private_key
  end
end
