# Shipvine

## Installation

```ruby
gem 'shipvine'
```

## Configuration

```ruby
Shipvine.api_key = ENV['SHIPVINE_API_KEY']
Shipvine.merchant_code = ENV['SHIPVINE_MERCHANT_CODE']

# optional, if you want to disable XML validation
Shipvine.validate_xml = false

# optional, if you want to use HTTPParty's debugging
if !Rails.env.production?
  Shipvine::Client.debug_output $stdout
end

```

## Usage

An example fulfillment request:

```ruby
fulfillment_request = Shipvine::FulfillmentRequest.new(
  merchant_identifier: order_id,
  email_address: email,
  first_name: first_name,
  last_name: last_name,
  address: {
    company: company,
    address1: address1,
    address2: address2,
    city_or_town: city,
    state_or_province: state,
    postal_code: zipcode,
    phone: phone,
  },
  lines: items,
  shipping_method: shipping_method,
  # optional
  metadata: {
    channel: channel,
    environment: Rails.env
  }
)

fulfillment_request.create
```

#### FulfillmentRequest

* Discount, tax, and shipping is set to 0 USD. If you need to pass the actual values, submit a PR adding the feature to pass these values to the fulfillment request.
* First name, last name is required. The company name is used if no name is defined.
* `ShipVine::FulfillmentRequest#get_shipvine_identifier` will throw a 404 if the fulfillment request is not shipped

## Development

http://support.shipvine.com/articles/index

TODO tests

* `deep_compact!` is added to `Hash` and `Array`
