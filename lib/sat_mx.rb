# frozen_string_literal: true

require_relative "sat_mx/version"

module SatMx
  class Error < StandardError; end
  autoload(:Authentication, "sat_mx/authentication")
end
