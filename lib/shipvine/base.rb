module Shipvine
  class Base
    WAREHOUSE_XSD_FILE = File.expand_path('../../../data/WarehouseFS-1.0.xsd', __FILE__)

    def self.client
      @client ||= Shipvine::Client.new
    end

    def self.xml_to_hash(raw_xml)
      Nori.new(:convert_tags_to => lambda { |tag| tag.snakecase.to_sym })
        .parse(raw_xml)
    end

    protected

      def client
        self.class.client
      end

      def add_xml_sequence(hash, order_array)
        hash[:order!] = order_array.select { |field| hash.keys.include?(field) }
      end

      def add_sequence_annotations(root_hash)
        puts "ShipVine: add_sequence_annotations not defined for #{self.class}"
      end

      def request_body(resource_name, attributes_hash)
        sanitized_hash = build_sanitized_hash(resource_name, attributes_hash)

        add_sequence_annotations(sanitized_hash[resource_name])

        request_xml = Gyoku.xml(sanitized_hash, {
          :key_converter => :camelcase
        })

        if Shipvine.validate_xml.nil? || Shipvine.validate_xml
          validate_xml!(request_xml)
        end

        request_xml
      end

      def build_sanitized_hash(resource_name, hash)
        # ShipVine doesn't accept `xsi:nil=true` attributes; these must be stripped
        # before performing hash => XML conversion
        sanitized = hash.deep_compact!

        {
          resource_name => {
            :@xmlns => 'urn:WarehouseFS-1.0',
            :merchant_code => Shipvine.merchant_code
          }.merge(sanitized)
        }
      end

      def validate_xml!(xml)
        xsd = Nokogiri::XML::Schema(File.read(WAREHOUSE_XSD_FILE))
        doc = Nokogiri::XML(xml)

        errors = xsd.validate(doc)

        if !errors.empty?
          puts xml
          raise "Error validating XML: #{errors.join("\n")}"
        end
      end
  end
end
