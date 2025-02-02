module SatMx
  class DownloadPetitionBody
    include Body

    def initialize(package_id:, requester_rfc:, certificate:)
      @package_id = package_id
      @requester_rfc = requester_rfc
      @certificate = certificate
    end

    def generate
      envelope do |xml|
        xml[Body::DES].PeticionDescargaMasivaTercerosEntrada do
          xml[Body::DES].peticionDescarga(
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
