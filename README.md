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

# optional
Shipvine.testmode = true

# optional, if you want to use HTTPParty's debugging
if !Rails.env.production?
  Shipvine::Client.debug_output $stdout
end

```

## Usage

#### FulfillmentRequest

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

* Discount, tax, and shipping is set to 0 USD. If you need to pass the actual values, submit a PR adding the feature to pass these values to the fulfillment request.
* First name, last name is required. The company name is used if no name is defined.
* `ShipVine::FulfillmentRequest#get_shipvine_identifier` will throw a 404 if the fulfillment request is not shipped

#### Item & Item Group

```ruby

item_group = Shipvine::ItemGroup.new(
  merchant_identifier: 'group-name',
  name: 'group-name',
  harmonized_code: '6105100000',
  country_of_origin: 'US'
)

item_group.create

item = Shipvine::Item.new(
  group_merchant_identifier: 'group-name'
  merchant_identifier: 'item-sku',
  name: 'item-name',
  harmonized_code: '6105100000',
  country_of_origin: 'US',
  weight: {
    magnitude: 0.25,
    unit: 'Pounds'
  },
  barcodes: {
    barcode: 'UPC'
  },
  metadata: {
    environment: Rails.env,
  }
)

item.create
```

## Development

* ShipVine API docs: http://support.shipvine.com/articles/index
* Harmonized Codes: https://uscensus.prod.3ceonline.com/

## Notes

* `deep_compact!` is added to `Hash` and `Array`. This might cause issues if this gem is used in larger applications. Feel free to submit a PR :)
* There are no tests for this gem. It is tested via integration tests in another project.
