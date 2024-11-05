require "openssl"
require "httpx"
require "xmldsig"
require "time"

module SatMx
  class Authentication
    AUTH_URL = "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/Autenticacion/Autenticacion.svc".freeze
    HEADERS = {
      "content-type" => "text/xml; charset=utf-8",
      "accept" => "text/xml",
      "SOAPAction" => "http://DescargaMasivaTerceros.gob.mx/IAutenticacion/Autentica"
    }.freeze
    private_constant :AUTH_URL
    private_constant :HEADERS

    def self.authenticate(certificate:, private_key:, id: nil)
      instance = if id.nil?
        new(
          xml_auth_body: XmlAuthBody.new(
            certificate:,
            private_key:
          )
        )
      else
        new(
          xml_auth_body: XmlAuthBody.new(
            certificate:,
            private_key:,
            id:
          )
        )
      end

      instance.authenticate
    end

    def initialize(xml_auth_body:)
      @xml_auth_body = xml_auth_body
    end

    def authenticate
      response = HTTPX.post(
        AUTH_URL,
        headers: HEADERS,
        body: xml_auth_body.sign
      )

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

    attr_reader :xml_auth_body
  end

  class XmlAuthBody
    def initialize(certificate:, private_key:, id: "uuid-#{SecureRandom.uuid}-1")
      @certificate = certificate
      @private_key = private_key
      @id = id
    end

    def sign
      Xmldsig::SignedDocument.new(xml_document).sign do |data|
        private_key.sign(OpenSSL::Digest.new("SHA1"), data)
      end
    end

    private

    attr_reader :private_key, :certificate, :id

    def xml_document
      <<~XML
        <S11:Envelope xmlns:S11="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
          <S11:Header>
            <wsse:Security S11:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
              #{timestamp}
              <wsse:BinarySecurityToken wsu:Id="#{id}" ValueType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3" EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">#{Base64.strict_encode64(certificate.to_der)}</wsse:BinarySecurityToken>
              <Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
                #{signed_info}
                <SignatureValue></SignatureValue>
                <KeyInfo>
                  <wsse:SecurityTokenReference>
                    <wsse:Reference ValueType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3" URI="##{id}" />
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
  end
end
