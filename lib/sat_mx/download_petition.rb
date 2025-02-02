module SatMx
  class DownloadPetition
    def self.call(package_id:, requester_rfc:, access_token:, certificate:, private_key:)
      new(
        body: DownloadPetitionBody.new(
          package_id:,
          requester_rfc:,
          certificate:
        ),
        client: Client.new(private_key:, access_token:)
      ).call
    end

    def initialize(body:, client:)
      @body = body
      @client = client
    end

    def call
      response = client.download_petition(body.generate)

      case response.status
      when 200..299
        xml = response.xml
        response_tag = xml.xpath(
          "//xmlns:respuesta",
          xmlns: "http://DescargaMasivaTerceros.sat.gob.mx"
        )[0]

        if response_tag["CodEstatus"] == "5000"
          Result.new(
            success?: true,
            xml: response.xml,
            value: response.xml.xpath(
              "//xmlns:Paquete",
              xmlns: "http://DescargaMasivaTerceros.sat.gob.mx"
            ).inner_text
          )
        else
          Result.new(
            success?: false,
            xml: response.xml,
            value: {
              CodEstatus: response_tag["CodEstatus"],
              Mensaje: response_tag["Mensaje"]
            }
          )
        end
      when 400..599
        Result.new(
          success?: false,
          xml: nil,
          value: nil
        )
      else
        SatMx::Error
      end
    end

    private

    attr_reader :client, :body
  end
end
