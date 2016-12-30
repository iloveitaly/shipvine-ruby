module Shipvine
  class Error < StandardError
    attr_reader :code, :shipvine_message

    def initialize(response = nil)
      if response.present?
        @code = response.code
        @shipvine_message = response.parsed_response["Errors"]["Error"]["Message"]
      end
    end
  end
end
