module SatMx
  S11 = "S11"
  XMLNS = "xmlns"
  DES = "des"
  DS = "ds"

  ENVELOPE_ATTRS = {
    "#{XMLNS}:#{S11}" => "http://schemas.xmlsoap.org/soap/envelope/",
    "#{XMLNS}:#{DES}" => "http://DescargaMasivaTerceros.sat.gob.mx",
    "#{XMLNS}:#{DS}" => "http://www.w3.org/2000/09/xmldsig#"
  }.freeze
end
