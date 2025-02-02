require "nokogiri"

RSpec.describe SatMx::DownloadPetitionBody, :with_certificate do
  describe "#generate" do
    let(:package_id) { "99999999-X99-9XX9-XX99-999X9X99X999_01" }
    let(:requester_rfc) { "AAA010101AAA" }

    it do
      body = described_class.new(package_id:, requester_rfc:, certificate:)

      expect(Nokogiri::XML::Document.parse(body.generate)).to be_same_xml(expected_xml)
    end

    private

    def expected_xml
      Nokogiri::XML.parse(
        <<~XML.strip
          <S11:Envelope xmlns:S11="http://schemas.xmlsoap.org/soap/envelope/" xmlns:des="http://DescargaMasivaTerceros.sat.gob.mx" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
            <S11:Header/>
            <S11:Body>
              <des:PeticionDescargaMasivaTercerosEntrada>
                <des:peticionDescarga IdPaquete="99999999-X99-9XX9-XX99-999X9X99X999_01" RfcSolicitante="AAA010101AAA">
                  <Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
                    <SignedInfo>
                      <CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />
                      <SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" />
                      <Reference URI="">
                        <Transforms>
                          <Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
                        </Transforms>
                        <DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" />
                        <DigestValue/>
                      </Reference>
                    </SignedInfo>
                    <SignatureValue/>
                    <KeyInfo>
                      <X509Data>
                        <X509IssuerSerial>
                          <X509IssuerName>emailAddress=info@mifiel.com,CN=Mifiel Intermediate,O=Mifiel,C=MX</X509IssuerName>
                          <X509SerialNumber>9510</X509SerialNumber>
                        </X509IssuerSerial>
                        <X509Certificate>MIIGDTCCA/WgAwIBAgICJSYwDQYJKoZIhvcNAQELBQAwXDELMAkGA1UEBhMCTVgxDzANBgNVBAoMBk1pZmllbDEcMBoGA1UEAwwTTWlmaWVsIEludGVybWVkaWF0ZTEeMBwGCSqGSIb3DQEJARYPaW5mb0BtaWZpZWwuY29tMB4XDTI0MDExODAwMDIzMFoXDTI5MDExNjAwMDIzMFowgeMxHTAbBgNVBAMMFEVtcHJlc2EgTG9jYWwgS2lrb3lhMR0wGwYDVQQpDBRFbXByZXNhIExvY2FsIEtpa295YTEdMBsGA1UECgwURW1wcmVzYSBMb2NhbCBLaWtveWExCzAJBgNVBAYTAk1YMTMwMQYJKoZIhvcNAQkBFiRvc2NhcitlbXByZXNhLWxvY2FsLWtpa295YUBraWtveWEuaW8xJTAjBgNVBC0MHEVMSzI0MDEwMTVMMiAvIExBTEwyMDAxMDFETkExGzAZBgNVBAUTEkxBTEwyMDAxMDFIQVNOTkwwMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALW399A+eD7rs5gVkyVHh5kgeJi+ImTR3q4JSVOFWUNOu9saN+djIgYvKOeIBax4wTXwAx+DIoBS0fJ2qeq3n2CvFP3a8ILoYMUs24HfHssbYEbv6Aj78uNKk/8qZKI+s18tfLXFK+udI6PzEQ7bA8TSCiKhZoTUPMh8KbsKylDiT3uGnOrB+jwbriRqtOjIAcGwtB7uxtx8e7UhWt+wYlrKhOFx2CfaVbg3b75z647Jyj4EqfiSDirQikkgabu1u8lztx6FsGpgkij43q3YN7P6czlXtjoyDKZMs061dsIsH1r+ggaHkSX5VhzldIw9aWog4vIm937bXTQIhKm/MvcCAwEAAaOCAU8wggFLMAkGA1UdEwQCMAAwEQYJYIZIAYb4QgEBBAQDAgZAMDMGCWCGSAGG+EIBDQQmFiRPcGVuU1NMIEdlbmVyYXRlZCBTZXJ2ZXIgQ2VydGlmaWNhdGUwHQYDVR0OBBYEFEfmExlKtajNklI0XnbVwP47ePRHMIGxBgNVHSMEgakwgaaAFByXFdVffbe67+F5tY+xObnG1LzIoYGJpIGGMIGDMQswCQYDVQQGEwJNWDEMMAoGA1UECAwDR0RMMQwwCgYDVQQHDANHREwxDzANBgNVBAoMBk1pZmllbDERMA8GA1UECwwIU2VjdXJpdHkxFDASBgNVBAMMC01pZmllbCBNYWluMR4wHAYJKoZIhvcNAQkBFg9pbmZvQG1pZmllbC5jb22CAhABMA4GA1UdDwEB/wQEAwIFoDATBgNVHSUEDDAKBggrBgEFBQcDATANBgkqhkiG9w0BAQsFAAOCAgEAi7qmlBax0n85SFNjJz1YyDnBPXXqTRE6RKfB/p5H5NYE44Swsm+4xMFSoTnixX1WS1/k7tR8d1MmGVKxXDKbDL25RhnjoLK5w2Bxp8g+2XiMRP9b1Y+fg7fwOzWbyBV1UR5QQzGCJ1b0kK0WNKZSJbCoF9afF0LykmsAbD5GC4Qe8hgEvqjWu/43KIag0e0h1UrQBcRE034+ZACHidRQZO4sGv+UKNgcYZjpbWMxNfC8+9YI/K0A0ywH8gECoAHOGh7zGZ+ToWanjNj4clbM8uygGA+f1ZxjmwAntaO/M3hfV2kBqsSETR9QVa3oHcy9r4t0Xk4ewoxjMA/dgJ/S6SESCzp2PYziCg5WGkb4a1kSKqlN8aqcLe+rJauXJAeUcW2KPT6PJuhRUfWRppp9d/v0haRotcde0ESMYPKwq8QOH+xkQJkFUI/5oTqhRvo67UJiDNBv7Rjt/vCGL6EBDz9XU/ka2Hvxc4xvTaReTv1ZpprTDHX0a/XnsN9V4zsY/Q2d85DbXntvdBpVWPWqqGQUFNM8qSVqr1K4M6BhWPRaJ0tDxFcXFRzvnBHyCPbeJ3tRNcnmdmy+ANYIAiZgHZcpq7kmK2NKEM03I05vFxWBrFU82Rhod43O+tl8LwJxP/eIg6TSZLpXz8Sy01OfgH+xjZZJA+p9vV4/kd/1SsY=</X509Certificate>
                      </X509Data>
                    </KeyInfo>
                  </Signature>
                </des:peticionDescarga>
              </des:PeticionDescargaMasivaTercerosEntrada>
            </S11:Body>
          </S11:Envelope>
        XML
      )
    end
  end
end
