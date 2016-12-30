module Shipvine
  class Client
    include HTTParty
    base_uri 'https://api.warehousefs.com/public/v1/'

    def initialize(opts = {})
      @options = opts
    end

    def request(method, resource, params = {})
      options = default_options.deep_merge(@options)

      options = if method == :get
        options.merge(query: sanitize_query_parameters(params))
      else
        # TODO a sanitization method is needed here
        options.merge(body: params)
      end

      response = self.class.send(method, resource, options)

      # NOTE response will be nil if the body of the response is nil

      if response.code != 200
        # TODO response.response.message == 'Unauthorized' in the case of 401
        #      possibly try to sniff out more descriptive error information

        fail Shipvine::Error.new(response), "#{response.code} #{response.body}"
      else
        response
      end
    end

    protected

      def sanitize_query_parameters(params)
        params = params.dup

        # TODO dynamic for input params hyphen/kebab case conversion
        # TODO stop hard coding shipvine parameter possibilities here

        params.each do |k, v|
          # force iso8601 on date/time
          if %w(created-since changed-since).include?(k) && [ DateTime, Date, Time ].include?(v.class)
            params[k] = v.iso8601
          end
        end

        { 'merchant-code' => Shipvine.merchant_code }.merge(params)
      end

      def default_options
        opts = {
          headers: {
            'X-Api-Key' => Shipvine.api_key
          }
        }

        if Shipvine.testmode
          opts[:headers]['X-Api-Test'] = 'true'
        end

        opts
      end

      def sanitize_body_parameters
        # ruby has to xml
      end
  end
end
