module SatMx
  class VerifyRequestBody
    include Body

    def initialize(certificate:, request_id:, requester_rfc:)
      @certificate = certificate
      @request_id = request_id
      @requester_rfc = requester_rfc
    end

    def generate
      envelope do |xml|
        xml[Body::DES].VerificaSolicitudDescarga do
          xml[Body::DES].solicitud(
            "IdSolicitud" => request_id,
            "RfcSolicitante" => requester_rfc
          ) do
            signature(xml)
          end
        end
      end
    end

    private

    attr_reader :certificate, :request_id, :requester_rfc
  end
end
