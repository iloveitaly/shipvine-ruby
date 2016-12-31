module Shipvine
  class ItemGroup < Base

    def self.get(item_merchant_identifier)
      request = self.client.request(
        :get,

        # TODO escape SKU?

        '/item-groups/' +
          Shipvine.merchant_code + '/' +
          item_merchant_identifier
      )

      self.new(self.xml_to_hash(request.body))
    rescue Shipvine::Error => e
      nil
    end

    attr_accessor :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def create
      translated_payload = @attributes.deep_dup

      merchant_identifier = translated_payload.delete(:merchant_identifier)

      client.request(
        :put,
        '/item-groups/' +
          Shipvine.merchant_code + '/' + merchant_identifier,
        request_body('ItemGroup', translated_payload)
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

  end
end
