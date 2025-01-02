# frozen_string_literal: true

module SatMx
  class DownloadPetition
    def self.call(package_id:, requester_rfc:, access_token:, certificate:, private_key:)
      new(
        body: DownloadPetitionBody.new(
          package_id:,
          requester_rfc:,
          certificate:
        ),
        client: Client.new(private_key:, access_token:)
      ).call
    end

    def initialize(body:, client:)
      @body = body
      @client = client
    end

    def call
      Result.new(success?: true, xml: "xml", value: "")
    end
  end
end
