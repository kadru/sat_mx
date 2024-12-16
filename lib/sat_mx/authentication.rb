require "httpx"
require "time"
require "base64"

module SatMx
  class Authentication
    def self.authenticate(certificate:, private_key:, uuid: SecureRandom.uuid)
      new(
        xml_auth_body: XmlAuthBody.new(
          certificate:,
          uuid:
        ),
        client: Client.new(
          private_key:,
          access_token: ""
        )
      ).authenticate
    end

    def initialize(xml_auth_body:, client:)
      @xml_auth_body = xml_auth_body
      @client = client
    end

    def authenticate
      response = client.authenticate(xml_auth_body.generate)

      case response.status
      when 200..299
        Result.new(success?: true,
          value: response.xml.xpath("//xmlns:AutenticaResult",
            xmlns: "http://DescargaMasivaTerceros.gob.mx").inner_text,
          xml: response.xml)
      when 400..599
        Result.new(success?: false, value: nil, xml: response.xml)
      else
        SatMx::Error
      end
    end

    private

    attr_reader :xml_auth_body, :client
  end

  class XmlAuthBody
    def initialize(certificate:, uuid:)
      @certificate = certificate
      @uuid = uuid
    end

    def generate
      <<~XML
        <S11:Envelope xmlns:S11="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
          <S11:Header>
            <wsse:Security S11:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
              #{timestamp}
              <wsse:BinarySecurityToken wsu:Id="#{uuid}" ValueType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3" EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">#{Base64.strict_encode64(certificate.to_der)}</wsse:BinarySecurityToken>
              <Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
                #{signed_info}
                <SignatureValue></SignatureValue>
                <KeyInfo>
                  <wsse:SecurityTokenReference>
                    <wsse:Reference ValueType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3" URI="##{uuid}" />
                  </wsse:SecurityTokenReference>
                </KeyInfo>
              </Signature>
            </wsse:Security>
          </S11:Header>
          <S11:Body>
            <Autentica xmlns="http://DescargaMasivaTerceros.gob.mx" />
          </S11:Body>
        </S11:Envelope>
      XML
    end

    private

    attr_reader :certificate

    def timestamp
      current_time = Time.now.utc
      <<~XML
        <wsu:Timestamp wsu:Id="_0">
          <wsu:Created>#{current_time.iso8601(3)}</wsu:Created>
          <wsu:Expires>#{(current_time + 300).iso8601(3)}</wsu:Expires>
        </wsu:Timestamp>
      XML
    end

    def signed_info
      <<~XML
        <SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
          <CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />
          <SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" />
            <Reference URI="#_0">
              <Transforms>
                <Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />
              </Transforms>
              <DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" />
              <DigestValue></DigestValue>
            </Reference>
        </SignedInfo>
      XML
    end

    def uuid
      "uuid-#{@uuid}-1"
    end
  end
end
