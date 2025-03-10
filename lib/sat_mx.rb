require "httpx"
require_relative "sat_mx/version"

module SatMx
  class Error < StandardError; end
  autoload(:Configuration, "sat_mx/configuration")
  autoload(:Authentication, "sat_mx/authentication")
  autoload(:DownloadRequest, "sat_mx/download_request")
  autoload(:DownloadRequestBody, "sat_mx/download_request_body")
  autoload(:VerifyRequest, "sat_mx/verify_request")
  autoload(:VerifyRequestBody, "sat_mx/verify_request_body")
  autoload(:DownloadPetition, "sat_mx/download_petition")
  autoload(:DownloadPetitionBody, "sat_mx/download_petition_body")
  autoload(:Body, "sat_mx/body")
  autoload(:Result, "sat_mx/result")
  autoload(:Signer, "sat_mx/signer")
  autoload(:Client, "sat_mx/client")

  class << self
    # Configures the gem using a block, its not threadsafe, so its recommended call only when you're initializing
    # your application, e.g. in your initializers directory of your rails app
    #  @example
    #   SatMx.configure do |config|
    #     config[:certificate] = "path/to/certificate.cer"
    #     config[:private_key] = "path/to/private.key"
    #     config[:password] = "key_password"
    #   end
    def configure
      config = {}
      yield(config)
      @configuration = Configuration.new(**config)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    # Authenticates with the SAT web service using the configured certificate and private key.
    # This method uses SOAP to communicate with the SAT authentication service and returns
    # a token that can be used for subsequent requests.
    #
    #   result = SatMx.authenticate
    #   if result.success?
    #     puts "Authentication token: #{result.value}"
    #   else
    #     puts "Authentication failed"
    #   end
    #
    # @return [SatMx::Result] A Result object containing:
    #   - success?: [Boolean] whether the authentication was successful
    #   - value: [String, nil] the authentication token if successful, nil otherwise
    #   - xml: [Nokogiri::XML::Document] the raw XML response from the service
    #
    # @see SatMx::Authentication
    # @see SatMx::Result
    def authenticate
      Authentication.authenticate(
        certificate: configuration.certificate,
        private_key: configuration.private_key
      )
    end
  end
end
