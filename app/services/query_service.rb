# frozen_string_literal: true
require 'typhoeus'
require 'uri'
require 'oj'

module QueryService
  class << self
    def connect_to_query_service(service_method, query_params=nil, sql_params=nil, geostore=nil)
      # http://staging-api.globalforestwatch.org
      url = if service_method.include?('fs2SQL')
              URI.decode("#{Service::SERVICE_URL}/convert/fs2SQL?#{query_params}")
            else
              URI.decode("#{Service::SERVICE_URL}/convert/sql2SQL?sql=#{sql_params}")
            end
      url += "&geostore=#{geostore}" if geostore.present?

      headers = {}
      headers['Accept']         = 'application/json'
      headers['Content-Type']   = 'application/json'
      headers['authentication'] = Service::SERVICE_TOKEN

      Typhoeus::Config.memoize = true
      hydra    = Typhoeus::Hydra.new max_concurrency: 100
      @request = Typhoeus::Request.new(URI.escape(url), method: :get, headers: headers, followlocation: true)

      @request.on_complete do |response|
        if response.success?
          @data = Oj.load(response.body.force_encoding(Encoding::UTF_8))['data']['attributes']['query'] || Oj.load(response.body.force_encoding(Encoding::UTF_8))
        elsif response.timed_out?
          @data = 'got a time out'
        elsif response.code.zero?
          @data = response.return_message
        else
          @data = Oj.load(response.body)
        end
      end
      hydra.queue @request
      hydra.run
      @data
    end
  end
end
