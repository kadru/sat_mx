require_relative "body"

module SatMx
  # @api private
  class DownloadRequestReceived
    def self.call(start_date:,
      end_date:,
      request_type:,
      recipient_rfc:,
      access_token:,
      certificate:,
      private_key:,
      requester_rfc: nil,
      issuing_rfc: nil,
      complement: nil,
      document_status: nil)
      new(
        download_request_received_body: DownloadRequestReceivedBody.new(
          start_date:,
          end_date:,
          request_type:,
          recipient_rfc:,
          requester_rfc:,
          certificate:,
          issuing_rfc:,
          complement:,
          document_status:
        ),
        client: Client.new(private_key:, access_token:)
      ).call
    end

    def initialize(download_request_received_body:, client:)
      @download_request_received_body = download_request_received_body
      @client = client
    end

    def call
      if (validation_error = validate_complement!)
        return validation_error
      end

      if (validation_error = validate_document_status!)
        return validation_error
      end

      response = client.download_request_received(download_request_received_body.generate)

      case response.status
      when 200..299
        check_body_status response.xml
      when 400..599
        Result.new(success?: false, value: nil, xml: response.xml)
      else
        Error
      end
    end

    private

    attr_reader :download_request_received_body, :client

    def validate_complement!
      complement = download_request_received_body.complement
      return unless complement
      return if DownloadRequestReceivedBody::COMPLEMENT_TYPES.include?(complement)

      Result.new(
        success?: false,
        value: {cod_estatus: "INVALID_COMPLEMENT", mensaje: "Invalid complement type: #{complement}"},
        xml: nil
      )
    end

    def validate_document_status!
      document_status = download_request_received_body.document_status
      return unless document_status
      return if DownloadRequestReceivedBody::DOCUMENT_STATUS.include?(document_status)

      Result.new(
        success?: false,
        value: {cod_estatus: "INVALID_DOCUMENT_STATUS", mensaje: "Invalid document status: #{document_status}"},
        xml: nil
      )
    end

    def check_body_status(xml)
      download_result_tag = xml.xpath(
        "//xmlns:SolicitaDescargaRecibidosResult",
        xmlns: Body::NAMESPACE
      )
      if download_result_tag.attr("CodEstatus").value == "5000"
        Result.new(
          success?: true,
          value: download_result_tag.attr("IdSolicitud").value,
          xml:
        )
      else
        Result.new(
          success?: false,
          value: {
            cod_estatus: download_result_tag.attr("CodEstatus").value,
            mensaje: download_result_tag.attr("Mensaje").value
          },
          xml:
        )
      end
    end
  end
end
