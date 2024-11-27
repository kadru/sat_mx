module NetworkStubs
  private

  def stub_download_request_failure
    stub_download_request
      .to_return(
        status: 400,
        body: fixture("authentication/failure_auth_response.xml"),
        headers: {
          "content-type" => "text/xml; charset=utf-8",
          "content-encoding" => "gzip",
          "vary" => "Accept-Encoding",
          "server" => "Microsoft-IIS/10.0",
          "x-content-type-options" => "nosniff",
          "x-xss-protection" => "1",
          "strict-transport-security" => "max-age=31536000; includeSubDomains",
          "x-frame-options" => "SAMEORIGIN",
          "date" => "Mon, 30 Sep 2024 20:30:10 GMT"
        }
      )
  end

  def stub_download_request_success
    stub_download_request
      .to_return(
        status: 200,
        body: fixture("download_request/response.xml"),
        headers: {
          "content-type" => "text/xml; charset=utf-8",
          "content-encoding" => "gzip",
          "vary" => "Accept-Encoding",
          "server" => "Microsoft-IIS/10.0",
          "x-content-type-options" => "nosniff",
          "x-xss-protection" => "1",
          "strict-transport-security" => "max-age=31536000; includeSubDomains",
          "x-frame-options" => "SAMEORIGIN",
          "date" => "Mon, 30 Sep 2024 20:30:10 GMT"
        }
      )
  end

  def stub_download_request
    stub_request(:post,
      "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/SolicitaDescargaService.svc")
      .with(
        body: request_body,
        headers: {
          "Accept" => "text/xml",
          "Accept-Encoding" => "gzip, deflate",
          "Authorization" => 'WRAP access_token="FAKE_ACCESS_TOKEN"',
          "Content-Type" => "text/xml; charset=utf-8",
          "Soapaction" => "http://DescargaMasivaTerceros.sat.gob.mx/ISolicitaDescargaService/SolicitaDescarga"
        }
      )
  end

  def request_body
    "<?xml version=\"1.0\"?>\n<S11:Envelope xmlns:S11=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:des=\"http://DescargaMasivaTerceros.sat.gob.mx\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\">\n  <S11:Header/>\n  <S11:Body>\n    <des:SolicitaDescarga>\n      <des:solicitud FechaInicial=\"2024-10-01T00:00:00\" FechaFinal=\"2024-10-21T00:00:00\" RfcEmisor=\"MOCR690424NZ5\" RfcSolicitante=\"AAA010101AAA\" TipoSolicitud=\"CFDI\">\n        <des:RfcReceptores>\n          <des:RfcReceptor>AAA010101AAA</des:RfcReceptor>\n        </des:RfcReceptores>\n        <Signature xmlns=\"http://www.w3.org/2000/09/xmldsig#\">\n          <SignedInfo>\n            <CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n            <SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n            <Reference URI=\"\">\n              <Transforms>\n                <Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/>\n              </Transforms>\n              <DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/>\n              <DigestValue>JdmZ7cm/RLEJSrwRGDNTEEwB8no=</DigestValue>\n            </Reference>\n          </SignedInfo>\n          <SignatureValue>BKeapu/h+7jWtM3HjCYi+H7g6VPs45q6Lr6pKLj4ETGGCif2enYL6+0GZVZ/ya0n/UBCeAupaDqvjhHNpp/R9TXYSLsCmNmfDPIFp0MqWn+3u9G7mVZdE0b+pMqy76aJxKIy0x5gDbAQwlNFeLERMZJXIBEqj22B9dTYWe9sDdWDpZGmIP3yLPKu4TWkEhYFRal1T5xV6KIEpsGnZ2stALp0gFKfU5dLD7kiUTM0ToSNAFmMoAynOxaZ6d8mccBoPyk2Zf0+oBFM/umsMLZxcCaFvBlb4UqH1y6VQB6gcdEK4/7CdfnjRaayIiCsFUW+kaz8g6VTgG/ETzd7Lw1ypg==</SignatureValue>\n          <KeyInfo>\n            <X509Data>\n              <X509IssuerSerial>\n                <X509IssuerName>emailAddress=info@mifiel.com,CN=Mifiel Intermediate,O=Mifiel,C=MX</X509IssuerName>\n                <X509SerialNumber>9510</X509SerialNumber>\n              </X509IssuerSerial>\n              <X509Certificate>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</X509Certificate>\n            </X509Data>\n          </KeyInfo>\n        </Signature>\n      </des:solicitud>\n    </des:SolicitaDescarga>\n  </S11:Body>\n</S11:Envelope>\n"
  end

  def stub_verify_request_success
    stub_request(:post,
      "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/VerificaSolicitudDescargaService.svc")
      .with(
        body: "",
        headers: {
          "Accept" => "text/xml",
          "Accept-Encoding" => "gzip, deflate",
          "Authorization" => 'WRAP access_token="FAKE_ACCESS_TOKEN"',
          "Content-Type" => "text/xml; charset=utf-8",
          "Soapaction" => "http://DescargaMasivaTerceros.sat.gob.mx/IVerificaSolicitudDescargaService/VerificaSolicitudDescarga"
        }
      )
  end
end

RSpec.configure do |config|
  config.include NetworkStubs
end
