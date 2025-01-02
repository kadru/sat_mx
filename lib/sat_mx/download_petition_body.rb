# frozen_string_literal: true

require "sat_mx/body_constants"

module SatMx
  class DownloadPetitionBody
    include Body
    include BodySignature

    def initialize(package_id:, requester_rfc:, certificate:)
      @package_id = package_id
      @requester_rfc = requester_rfc
      @certificate = certificate
    end

    def generate
      envelope do |xml|
        xml[DES].PeticionDescargaMasivaTercerosEntrada do
          xml[DES].peticionDescarga(
            IdPaquete: package_id,
            RfcSolicitante: requester_rfc
          ) do
            signature(xml)
          end
        end
      end
    end

    private

    attr_reader :package_id, :requester_rfc, :certificate
  end
end
