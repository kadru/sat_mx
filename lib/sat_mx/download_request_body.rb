require "time"

module SatMx
  class DownloadRequestBody
    include BodySignature

    REQUEST_TYPES = {
      cfdi: "CFDI",
      metadata: "Metadata"
    }.freeze

    def initialize(start_date:,
      end_date:,
      request_type:,
      issuing_rfc:,
      recipient_rfcs:,
      requester_rfc:,
      certificate:)
      @start_date = start_date
      @end_date = end_date
      @request_type = request_type
      @issuing_rfc = issuing_rfc
      @recipient_rfcs = recipient_rfcs
      @requester_rfc = requester_rfc
      @certificate = certificate
    end

    def generate
      Nokogiri::XML::Builder.new do |xml|
        xml[S11].Envelope(
          ENVELOPE_ATTRS
        ) do
          xml[S11].Header
          xml[S11].Body do
            xml[DES].SolicitaDescarga do
              xml[DES].solicitud(
                "FechaInicial" => start_date,
                "FechaFinal" => end_date,
                "RfcEmisor" => issuing_rfc,
                "RfcSolicitante" => requester_rfc,
                "TipoSolicitud" => request_type
              ) do
                xml[DES].RfcReceptores do
                  @recipient_rfcs.each do |rfc|
                    xml[DES].RfcReceptor(rfc)
                  end
                end
                signature(xml)
              end
            end
          end
        end
      end.doc.root.to_xml
    end

    private

    attr_reader :issuing_rfc, :requester_rfc, :certificate

    def start_date = @start_date.strftime("%Y-%m-%dT%H:%M:%S")

    def end_date = @end_date.strftime("%Y-%m-%dT%H:%M:%S")

    def request_type = REQUEST_TYPES.fetch(@request_type)
  end
end
