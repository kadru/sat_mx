# SatMx

Ruby client for SAT (Mexican Tax Administration) web services to download CFDI invoices.

## Installation

```bash
gem install sat_mx
```

Or add to your Gemfile:

```ruby
gem "sat_mx"
```

## Configuration

```ruby
SatMx.configure do |config|
  config[:certificate] = "path/to/certificate.cer"
  config[:private_key] = "path/to/private.key"
  config[:password] = "key_password"
end
```

## Usage

```ruby
# 1. Authenticate
result = SatMx.authenticate
raise "Auth failed" unless result.success?

token = result.value

# 2. Request download
result = SatMx.download_request(
  start_date: Time.new(2024, 1, 1),
  end_date: Time.new(2024, 1, 31),
  request_type: :cfdi,
  issuing_rfc: "ABC010101ABC",
  recipient_rfcs: ["XYZ020202XYZ"],
  requester_rfc: "ABC010101ABC",
  access_token: token
)
raise "Request failed" unless result.success?

request_id = result.value

# 3. Verify status (poll until ready)
loop do
  result = SatMx.verify_request(
    request_id: request_id,
    requester_rfc: "ABC010101ABC",
    access_token: token
  )

  case result.value[:request_status]
  when :finished
    break result.value[:package_ids]
  when :error, :rejected, :expired
    raise "Request failed: #{result.value}"
  end

  sleep 5
end

# 4. Download packages
package_ids.each do |package_id|
  result = SatMx.download_petition(
    package_id: package_id,
    requester_rfc: "ABC010101ABC",
    access_token: token
  )

  File.write("#{package_id}.zip", result.value) if result.success?
end
```

## API

| Method | Description |
|--------|-------------|
| `SatMx.configure` | Configure certificate and private key |
| `SatMx.configuration` | Get current configuration |
| `SatMx.authenticate` | Get access token |
| `SatMx.download_request` | Request CFDI download |
| `SatMx.verify_request` | Check request status |
| `SatMx.download_petition` | Download package |

All methods return a `Result` object with:
- `success?` - Boolean indicating success
- `value` - Data on success, error hash `{:cod_estatus, :mensaje}` on failure
- `xml` - Raw XML response

## License

MIT
