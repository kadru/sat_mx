# frozen_string_literal: true

require_relative "sat_mx/version"

module SatMx
  class Error < StandardError; end
  autoload(:Authentication, "sat_mx/authentication")
  autoload(:DownloadRequest, "sat_mx/download_request")
  autoload(:VerifyRequest, "sat_mx/verify_request")
  autoload(:VerifyRequestBody, "sat_mx/verify_request_body")
  autoload(:BodySignature, "sat_mx/body_signature")
  autoload(:Result, "sat_mx/result")
  autoload(:Signer, "sat_mx/signer")
end
