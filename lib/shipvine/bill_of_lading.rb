module Shipvine
  class BillOfLading < Base

    attr_accessor :formatted, :numeric

    def self.generate
      response = self.client.request(
        :post,
        '/bol-numbers/' + Shipvine.merchant_code,
        ''
      )

      lading = self.new
      lading.formatted = response["BillOfLadingNumber"]["Formatted"]
      lading.numeric = response["BillOfLadingNumber"]["Numeric"]

      lading
    end

  end
end
