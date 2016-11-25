# frozen_string_literal: true
require 'curb'
require 'typhoeus'
require 'uri'
require 'oj'
require 'yajl'

module ConnectorService
  class << self
    def connect_to_dataset_service(dataset_id, status)
      status = case status
               when 'saved'   then 1
               when 'deleted' then 3
               else 2
               end

      params = { dataset: { status: status } }
      url    = URI.decode("#{Service::SERVICE_URL}/dataset/#{dataset_id}")

      @c = Curl::Easy.http_put(URI.escape(url), Oj.dump(params)) do |curl|
        curl.headers['Accept']         = 'application/json'
        curl.headers['Content-Type']   = 'application/json'
        curl.headers['authentication'] = Service::SERVICE_TOKEN
      end
      @c.perform
    end

    def connect_to_provider(connector_url, data_path=nil, table_name=nil, attr_path=nil)
      if connector_url.include?('/tables/')
        select_limit = "select * from #{table_name} limit 1"
        if connector_url.include?('/u/')
          url = URI(connector_url)
          url_sub  = url.path.split(/u|tables/)[1].gsub('/','')
          url_host = 'carto.com'
          url = "#{url.scheme}://#{url_sub}.#{url_host}/api/v2/sql?q=#{select_limit}"
        else
          url = URI(connector_url)
          url = "#{url.scheme}://#{url.host}/api/v2/sql?q=#{select_limit}"
        end
      else
        url = URI.decode(connector_url)
      end

      headers = {}
      headers['Accept']       = 'application/json'
      headers['Content-Type'] = 'application/json'

      Typhoeus::Config.memoize = true
      hydra    = Typhoeus::Hydra.new max_concurrency: 100
      @request = Typhoeus::Request.new(URI.escape(url), method: :get, headers: headers, followlocation: true)

      @request.on_complete do |response|
        if response.success?
          parser = YAJI::Parser.new(response.body.force_encoding(Encoding::UTF_8))
          if data_path.present?
            @data  = []
            parser.each("/#{data_path}/") do |obj|
              obj.is_a?(String) ? @data = obj : @data << obj
            end
          elsif attr_path.present?
            parser = Yajl::Parser.new
            @data = parser.parse(response.body.force_encoding(Encoding::UTF_8))[attr_path] || parser.parse(response.body.force_encoding(Encoding::UTF_8))
          else
            parser = Yajl::Parser.new
            @data  = parser.parse(response.body.force_encoding(Encoding::UTF_8))
          end
          @data
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
