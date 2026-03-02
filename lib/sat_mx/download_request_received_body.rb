require "time"

module SatMx
  # @api private
  class DownloadRequestReceivedBody
    include Body

    REQUEST_TYPES = {
      cfdi: "CFDI",
      metadata: "Metadata"
    }.freeze

    DOCUMENT_STATUS = %w[
      Todos
      Cancelado
      Vigente
    ].freeze

    COMPLEMENT_TYPES = %w[
      acreditamientoieps10
      aerolineas
      certificadodedestruccion
      cfdiregistrofiscal
      comercioexterior10
      comercioexterior11
      comprobante
      consumodecombustibles
      consumodecombustibles11
      detallista
      divisas
      donat11
      ecc11
      ecc12
      gastoshidrocarbonos10
      iedu
      implocal
      ine11
      ingresoshidrocarbonos
      leyendasfisc
      nomina11
      nomina12
      notariospublicos
      obrasarteantiguedades
      pagoenespecie
      pagos10
      pfic
      renovacionysustitucionvehiculos
      servicioparcialconstruccion
      spei
      terceros11
      turistapasajeroextranjero
      valesdedespensa
      vehiculousado
      ventavehiculos11
    ].freeze

    def initialize(
      start_date:,
      end_date:,
      request_type:,
      recipient_rfc:,
      requester_rfc:,
      certificate:,
      issuing_rfc: nil,
      complement: nil,
      document_status: nil
    )
      @start_date = start_date
      @end_date = end_date
      @request_type = request_type
      @recipient_rfc = recipient_rfc
      @requester_rfc = requester_rfc
      @certificate = certificate
      @issuing_rfc = issuing_rfc
      @complement = complement
      @document_status = document_status
    end

    def generate
      envelope do |xml|
        xml[Body::DES].SolicitaDescargaRecibidos do
          attrs = {
            "FechaInicial" => start_date,
            "FechaFinal" => end_date,
            "TipoSolicitud" => request_type,
            "RfcReceptor" => recipient_rfc
          }
          attrs["RfcEmisor"] = issuing_rfc if issuing_rfc
          attrs["RfcSolicitante"] = requester_rfc if requester_rfc
          attrs["Complemento"] = complement if complement
          attrs["EstadoComprobante"] = document_status if document_status

          xml[Body::DES].solicitud(attrs) do
            signature(xml)
          end
        end
      end
    end

    attr_reader :complement, :document_status

    private

    attr_reader :recipient_rfc, :requester_rfc, :certificate, :issuing_rfc

    def start_date = @start_date.strftime("%Y-%m-%dT%H:%M:%S")

    def end_date = @end_date.strftime("%Y-%m-%dT%H:%M:%S")

    def request_type = REQUEST_TYPES.fetch(@request_type)
  end
end
