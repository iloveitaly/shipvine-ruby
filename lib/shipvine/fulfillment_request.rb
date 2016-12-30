module Shipvine
  class FulfillmentRequest < Base
    STATIC_REQUEST_ELEMENTS = {
      currency: 'USD',
      discount: {
        amount: 0.0,
        currency: 'USD'
      },
      tax: {
        amount: 0.0,
        currency: 'USD'
      },
      shipping: {
        amount: 0.0,
        currency: 'USD'
      }
    }.freeze

    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    # TODO split classes into FulfillmentRequestSubmission and FulfillmentRequest?

    def self.get_shipvine_identifier(merchant_identifier)
      request = self.client.request(
        :get,
        '/fulfillment-requests',
        {
          "merchant-identifier" => merchant_identifier
        }
      )

      request["FulfillmentRequests"]["FulfillmentRequest"]["ShipvineIdentifier"]
    rescue Shipvine::Error => e
      # NOTE SV will return a 404, or other non-200 response if the fulfillment does not exist
      nil
    end

    def self.get(shipvine_identifier)
      request = self.client.request(
        :get,
        '/fulfillment-requests/' + shipvine_identifier
      )

      self.new(self.xml_to_hash(request.body))
    end

    def metadata
      metadata_entries = self.attributes.dig(:fulfillment_request, :metadata, :metadata)

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

    def create
      translated_payload = @attributes.deep_dup

      preprocess_lines(translated_payload)
      preprocess_address(translated_payload)
      preprocess_metadata(translated_payload)
      add_static_elements(translated_payload)

      client.request(
        :post,
        '/fulfillment-request-submissions',
        request_body('FulfillmentRequestSubmission', translated_payload)
      )
    end

    protected

      def add_static_elements(order_hash)
        order_hash.merge!(STATIC_REQUEST_ELEMENTS)
      end

      def preprocess_metadata(order_hash)
        metadata = order_hash.delete(:metadata)

        if metadata
          order_hash[:request_metadata] = {
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
        items = order_hash.delete(:lines)

        order_hash[:lines] = {
          :line => items.map do |item|
            h = {
              item: {
                # TODO support other item keys, `sku`, `id`, etc
                merchant_identifier: item[:product_id]
              },
              quantity: item[:quantity],
              unit_price: {
                amount: 0.0,
                currency: 'USD'
              }
            }

            if item[:stored_value]
              h[:item][:stored_value] = {
                amount: item[:stored_value],
                currency: 'USD'
              }
            end

            if item[:gift_box]
              h[:item][:gift_box] = true
            end

            if item[:modifications]
              h[:item][:modifications] = {
                modification: item[:modifications]
              }
            end

            h
          end
        }

        order_hash
      end

      def preprocess_address(order_hash)
        order_hash[:address][:@type] = "Shipping"
        order_hash[:address][:country] ||= 'US'

        address1 = order_hash[:address].delete(:address1)
        address2 = order_hash[:address].delete(:address2)

        order_hash[:address][:street_lines] = {
          :street_line => [
            address1,
            address2
          ]
        }

        order_hash[:address][:personal_name] = {
          first: order_hash.delete(:first_name),
          last: order_hash.delete(:last_name)
        }

        # shipvine requires first and last; pull from company field if not defined
        if order_hash[:address][:personal_name][:first].blank? || order_hash[:address][:personal_name][:last].blank?
          if order_hash[:address][:company].nil? || order_hash[:address][:company].empty?
            fail "both name and company fields are empty, cannot create fulfillment"
          end

          first_name, last_name = order_hash[:address][:company].split(' ', 2)

          # NOTE first and last name are always required in ShipVine
          #      ensure that *some* value is always set

          if last_name.nil?
            last_name = first_name
          end

          if first_name.nil?
            first_name = last_name
          end

          order_hash[:address][:personal_name][:first] ||= first_name
          order_hash[:address][:personal_name][:last] ||= last_name
        end

        order_hash
      end

      def add_sequence_annotations(hash)
        add_xml_sequence(hash, %i(
          merchant_code
          merchant_identifier
          customer_identifier
          bill_of_lading_number
          currency
          email_address
          address
          lines
          requested_documents
          merchant_return_profile
          ucc_label_template
          packing_slip_template
          shipping_method
          shipping_charges_payer
          return_label
          discount
          tax
          shipping
          request_metadata
        ))

        add_xml_sequence(hash[:address], %i(
          country
          personal_name
          company
          street_lines
          city_or_town
          state_or_province
          postal_code
          phone
        ))

        hash[:lines][:line].each do |line|
          add_xml_sequence(line, %i(
            item
            quantity
            unit_price
          ))

          add_xml_sequence(line[:item], %i(
            merchant_identifier
            modifications
            stored_value
            gift_box
          ))
        end

        # TODO specify first and last order under `personal_name`
      end

  end
end
