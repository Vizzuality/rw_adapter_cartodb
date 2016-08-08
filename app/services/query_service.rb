require 'typhoeus'
require 'uri'
require 'oj'

class QueryService
  class << self
    def connect_to_query_service(service_method, query_params=nil, sql_params=nil)
      url = if service_method.include?('fs2SQL')
              URI.decode("#{ServiceSetting.gateway_url}/convert/fs2SQL?#{query_params}")
            else
              URI.decode("#{ServiceSetting.gateway_url}/convert/checkSQL?sql=#{sql_params}")
            end

      headers = {}
      headers['Accept']         = 'application/json'
      headers['Content-Type']   = 'application/json'
      headers['authentication'] = ServiceSetting.auth_token if ServiceSetting.auth_token.present?

      Typhoeus::Config.memoize = true
      hydra    = Typhoeus::Hydra.new max_concurrency: 100
      @request = ::Typhoeus::Request.new(URI.escape(url), method: :get, headers: headers, followlocation: true)

      @request.on_complete do |response|
        if response.success?
          # cool
        elsif response.timed_out?
          'got a time out'
        elsif response.code.zero?
          response.return_message
        else
          'HTTP request failed: ' + response.code.to_s
        end
      end

      hydra.queue @request
      hydra.run

      Oj.load(@request.response.body.force_encoding(Encoding::UTF_8))['data']['attributes']['query'] || Oj.load(@request.response.body.force_encoding(Encoding::UTF_8))
    end
  end
end
