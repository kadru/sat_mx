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
    # @param certificate [OpenSSL::X509::Certificate, nil] Certificate object (uses configuration if nil)
    # @param private_key [OpenSSL::PKey::RSA, nil] Private key object (uses configuration if nil)
    #
    # @return [SatMx::Result] A Result object containing:
    #   - success?: [Boolean] whether the authentication was successful
    #   - value: [String, nil] the authentication token if successful, nil otherwise
    #   - xml: [Nokogiri::XML::Document] the raw XML response from the service
    #
    # @see SatMx::Authentication
    # @see SatMx::Result
    def authenticate(certificate: nil, private_key: nil)
      cert = certificate || configuration.certificate
      key = private_key || configuration.private_key
      Authentication.authenticate(
        certificate: cert,
        private_key: key
      )
    end

    # Requests a download of CFDI documents from the SAT web service.
    #
    #   result = SatMx.download_request(
    #     start_date: Time.new(2024, 1, 1),
    #     end_date: Time.new(2024, 1, 31),
    #     request_type: :cfdi,
    #     issuing_rfc: "ABC010101ABC",
    #     recipient_rfcs: ["XYZ020202XYZ"],
    #     requester_rfc: "ABC010101ABC",
    #     access_token: "your_access_token"
    #   )
    #   if result.success?
    #     puts "Request ID: #{result.value}"
    #   else
    #     puts "Request failed: #{result.value}"
    #   end
    #
    # @param start_date [Time] Start date for the search range
    # @param end_date [Time] End date for the search range
    # @param request_type [Symbol] Type of request (:cfdi or :retentions)
    # @param issuing_rfc [String] RFC of the issuer
    # @param recipient_rfcs [Array<String>] RFCs of the recipients
    # @param requester_rfc [String] RFC of the requester
    # @param access_token [String] Authentication token from SatMx.authenticate
    # @param certificate [String, nil] Path to certificate file (uses configuration if nil)
    # @param private_key [String, nil] Path to private key file (uses configuration if nil)
    #
    # @return [SatMx::Result] A Result object containing:
    #   - success?: [Boolean] whether the request was successful
    #   - value: [String, nil] the request ID if successful, or {cod_estatus:, mensaje:} on failure
    #   - xml: [Nokogiri::XML::Document] the raw XML response from the service
    #
    # @see SatMx::DownloadRequest
    # @see SatMx::Result
    def download_request(start_date:, end_date:, request_type:, issuing_rfc:, recipient_rfcs:, requester_rfc:, access_token:, **options)
      certificate = options[:certificate] || configuration.certificate
      private_key = options[:private_key] || configuration.private_key
      DownloadRequest.call(
        start_date:,
        end_date:,
        request_type:,
        issuing_rfc:,
        recipient_rfcs:,
        requester_rfc:,
        access_token:,
        certificate:,
        private_key:
      )
    end

    # Verifies the status of a previously submitted download request.
    #
    #   result = SatMx.verify_request(
    #     request_id: "606c5667-345a-4630-8979-0769734ac80b",
    #     requester_rfc: "ABC010101ABC",
    #     access_token: "your_access_token"
    #   )
    #   if result.success?
    #     puts "Status: #{result.value[:request_status]}"
    #     puts "Packages: #{result.value[:package_ids]}"
    #   else
    #     puts "Verification failed: #{result.value}"
    #   end
    #
    # @param request_id [String] The ID returned from SatMx.download_request
    # @param requester_rfc [String] RFC of the requester
    # @param access_token [String] Authentication token from SatMx.authenticate
    # @param certificate [String, nil] Path to certificate file (uses configuration if nil)
    # @param private_key [String, nil] Path to private key file (uses configuration if nil)
    #
    # @return [SatMx::Result] A Result object containing:
    #   - success?: [Boolean] whether the verification was successful
    #   - value: [Hash, nil] containing :request_status and :package_ids if successful, or {cod_estatus:, mensaje:} on failure
    #   - xml: [Nokogiri::XML::Document] the raw XML response from the service
    #
    # @see SatMx::VerifyRequest
    # @see SatMx::Result
    def verify_request(request_id:, requester_rfc:, access_token:, **options)
      certificate = options[:certificate] || configuration.certificate
      private_key = options[:private_key] || configuration.private_key
      VerifyRequest.call(
        request_id:,
        requester_rfc:,
        access_token:,
        certificate:,
        private_key:
      )
    end

    # Downloads a package of CFDI documents from the SAT web service.
    #
    #   result = SatMx.download_petition(
    #     package_id: "18015570-C084-4BE8-BE36-476F5D46A133_01",
    #     requester_rfc: "ABC010101ABC",
    #     access_token: "your_access_token"
    #   )
    #   if result.success?
    #     File.write("package.zip", result.value)
    #   else
    #     puts "Download failed: #{result.value}"
    #   end
    #
    # @param package_id [String] The package ID from SatMx.verify_request
    # @param requester_rfc [String] RFC of the requester
    # @param access_token [String] Authentication token from SatMx.authenticate
    # @param certificate [String, nil] Path to certificate file (uses configuration if nil)
    # @param private_key [String, nil] Path to private key file (uses configuration if nil)
    #
    # @return [SatMx::Result] A Result object containing:
    #   - success?: [Boolean] whether the download was successful
    #   - value: [String, nil] Base64 encoded ZIP content if successful, or {cod_estatus:, mensaje:} on failure
    #   - xml: [Nokogiri::XML::Document] the raw XML response from the service
    #
    # @see SatMx::DownloadPetition
    # @see SatMx::Result
    def download_petition(package_id:, requester_rfc:, access_token:, **options)
      certificate = options[:certificate] || configuration.certificate
      private_key = options[:private_key] || configuration.private_key
      DownloadPetition.call(
        package_id:,
        requester_rfc:,
        access_token:,
        certificate:,
        private_key:
      )
    end
  end
end
