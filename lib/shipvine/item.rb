module Shipvine
  class Item < Base
    def self.get(item_group_merchant_identifier, item_merchant_identifier)
      request = self.client.request(
        :get,
        # escape SKU?

        '/item-groups/' +
          Shipvine.merchant_code + '/' +
          item_group_merchant_identifier + '/' +
          'items/' +
          item_merchant_identifier,
        {},
        exclude_merchant_code: true
      )

      self.new(self.xml_to_hash(request.body))
    rescue Shipvine::Error => e
      nil
    end

    def initialize(attributes)
      @attributes = attributes
    end

    def create
      translated_payload = @attributes.deep_dup

      merchant_identifier = translated_payload.delete(:merchant_identifier)
      group_merchant_identifier = translated_payload.delete(:group_merchant_identifier)

      preprocess_metadata(translated_payload)
      preprocess_variations(translated_payload)

      client.request(
        :put,
        '/item-groups/' +
          Shipvine.merchant_code + '/' +
          group_merchant_identifier + '/' +
          'items/' +
          merchant_identifier,
        request_body('Item', translated_payload),
        exclude_merchant_code: true
      )
    end

    private

      # NOTE there are no sequence limitations on the item API

      # there is no XSD, and the merchant code is included the URL; simple strip nils
      def build_sanitized_hash(resource_name, hash)
        { resource_name => hash.deep_compact! }
      end

      def validate_xml!(xml)
        # NOTE there is no XSD for item group!
      end

      def preprocess_variations(item_hash)
        variations = item_hash.delete(:variations)

        if variations
          item_hash[:variations] = {
            variation: variations
          }
        end
      end

      def preprocess_metadata(item_hash)
        metadata = item_hash.delete(:metadata)

        if metadata
          item_hash[:metadata] = {
            :metadata => metadata.map do |k, v|
              {
                name: k,
                value: v
              }
            end
          }
        end
      end
  end
end
