# frozen_string_literal: true

require_relative "sat_mx/version"

module SatMx
  class Error < StandardError; end
  autoload(:Authentication, "sat_mx/authentication")
  autoload(:DownloadRequest, "sat_mx/download_request")
  autoload(:DownloadRequestBody, "sat_mx/download_request_body")
  autoload(:VerifyRequest, "sat_mx/verify_request")
  autoload(:VerifyRequestBody, "sat_mx/verify_request_body")
  autoload(:DownloadPetition, "sat_mx/download_petition")
  autoload(:DownloadPetitionBody, "sat_mx/download_petition_body")
  autoload(:BodySignature, "sat_mx/body_signature")
  autoload(:Body, "sat_mx/body")
  autoload(:Result, "sat_mx/result")
  autoload(:Signer, "sat_mx/signer")
  autoload(:Client, "sat_mx/client")
end
