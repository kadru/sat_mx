require "base64"
require "sat_mx/body_constants"

module SatMx
  module BodySignature
    private

    def signature(xml)
      xml.Signature(XMLNS => "http://www.w3.org/2000/09/xmldsig#") do
        xml.SignedInfo do
          xml.CanonicalizationMethod("Algorithm" => "http://www.w3.org/TR/2001/REC-xml-c14n-20010315")
          xml.SignatureMethod("Algorithm" => "http://www.w3.org/2000/09/xmldsig#rsa-sha1")
          xml.Reference("URI" => "") do
            xml.Transforms do
              xml.Transform("Algorithm" => "http://www.w3.org/2000/09/xmldsig#enveloped-signature")
            end
            xml.DigestMethod("Algorithm" => "http://www.w3.org/2000/09/xmldsig#sha1")
            xml.DigestValue
          end
        end
        xml.SignatureValue
        xml.KeyInfo do
          xml.X509Data do
            xml.X509IssuerSerial do
              xml.X509IssuerName(certificate_issuer)
              xml.X509SerialNumber(certificate_serial)
            end
            xml.X509Certificate(encoded_certificate)
          end
        end
      end
    end

    def certificate_issuer = certificate.issuer.to_s(OpenSSL::X509::Name::RFC2253)

    def certificate_serial = certificate.serial

    def encoded_certificate = Base64.strict_encode64(certificate.to_der)
  end
end
