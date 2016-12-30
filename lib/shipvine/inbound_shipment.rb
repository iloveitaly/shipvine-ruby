module Shipvine
  class InboundShipment < Base

    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def self.list(since, state = 'Complete')
      request = self.client.request(
        :get,
        '/inbound-shipments/' + ERB::Util.url_encode(Shipvine.merchant_code),
        {
          'changed-since' => since,
          'state' => state
        }
      )

      response = self.xml_to_hash(request.body)

      # the GET response only returns the identifiers, we have to make another call
      # to pull all of the actual inbound shipments
      merchant_identifiers = Array.wrap(response.dig(:inbound_shipments, :inbound_shipment)).map do |shipment_hash|
        shipment_hash[:merchant_identifier]
      end

      merchant_identifiers.map do |identifier|
        self.get(identifier)
      end
    end

    def self.get(merchant_identifier)
      request = self.client.request(
        :get,
        '/inbound-shipments/' + ERB::Util.url_encode(Shipvine.merchant_code) + '/' + ERB::Util.url_encode(merchant_identifier)
      )

      self.new(self.xml_to_hash(request.body))
    end

    def create
      translated_payload = @attributes.deep_dup
      merchant_identifier = translated_payload.delete(:merchant_identifier)

      # `The /InboundShipment/ExpectedAt date is not in the expected format of yyyy-MM-dd (e.g., '2014-02-28')`
      if translated_payload[:expected_at] !=~ /[0-9]{4}-[0-2]{2}-[0-9]{2}/
        translated_payload[:expected_at] = DateTime.parse(translated_payload[:expected_at]).strftime('%Y-%m-%d')
      end

      preprocess_lines(translated_payload)
      preprocess_metadata(translated_payload)

      client.request(
        :put,
        '/inbound-shipments/' + ERB::Util.url_encode(Shipvine.merchant_code) + '/' + ERB::Util.url_encode(merchant_identifier),
        request_body('InboundShipment', translated_payload)
      )
    end

    def metadata
      metadata_entries = self.attributes.dig(:inbound_shipment, :shipment_metadata, :metadata)

      if metadata_entries.nil? || metadata_entries.empty?
        return {}
      end

      # TODO cache the resulting hash here

      metadata_entries = Array.wrap(metadata_entries)

      metadata_entries.inject({}) do |h, sv_metadata_entry|
        h[sv_metadata_entry[:name]] = sv_metadata_entry[:value]
        h
      end
    end

    protected

      def preprocess_metadata(shipment_hash)
        metadata = shipment_hash.delete(:metadata)

        if metadata
          shipment_hash[:shipment_metadata] = {
            :metadata => metadata.map do |k, v|
              {
                name: k,
                value: v
              }
            end
          }
        end
      end

      def preprocess_lines(order_hash)
        items = order_hash.delete(:items)

        order_hash[:lines] = {
          :line => items.map do |item|
            {
              item: {
                # TODO support other item keys, `sku`, `id`, etc
                merchant_identifier: item[:product_id]
              },
              quantity_expected: item[:quantity],
            }
          end
        }

        order_hash
      end

      def build_sanitized_hash(resource_name, hash)
        sanitized = hash.deep_compact!

        # NOTE inbound shipments do not have a XSD!
        #      also, the merchant code is specified in the URL in XML

        {
          resource_name => sanitized
        }
      end

      def validate_xml!(xml)
        # NOTE there is no XSD for inbound shipments!
      end

  end
end
