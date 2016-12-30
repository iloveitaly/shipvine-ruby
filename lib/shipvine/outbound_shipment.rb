module Shipvine
  class OutboundShipment < Base

    def self.list(since)
      request = self.client.request(:get, '/outbound-shipments', { 'created-since' => since })
      response = self.xml_to_hash(request.body)

      Array.wrap(response[:outbound_shipments][:outbound_shipment]).map do |shipment_hash|
        self.new(shipment_hash)
      end
    end

    attr_accessor :attributes

    def initialize(shipment_hash)
      @attributes = shipment_hash
    end

    def merchant_identifier
      @attributes[:fulfillment_request][:merchant_identifier]
    end

    def wfs_identifier
      @attributes[:fulfillment_request][:wfs_identifier]
    end

    alias_method :shipvine_identifier, :wfs_identifier

  end
end
