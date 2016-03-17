require 'typhoeus'
require 'uri'

class CartodbService
  def initialize(connect_data_url, connect_data_path, dataset_table_name, options = {})
    @connect_data_url   = connect_data_url
    @connect_data_path  = connect_data_path
    @dataset_table_name = dataset_table_name
    @options_hash       = options
    initialize_options
  end

  def connect_data
    query_to_run = if @options_hash.present?
                     "?q=#{options_query}"
                   else
                     "?q=#{index_query}"
                   end

    url =  URI.encode(@connect_data_url[/[^\?]+/])
    url += query_to_run

    url = URI.escape(url)

    @request = Typhoeus::Request.new(url, method: :get, followlocation: true)

    @request.on_complete do |response|
      if response.success?
        # cool
      elsif response.timed_out?
        # aw hell no
        log("got a time out")
      elsif response.code == 0
        # Could not get an http response, something's wrong.
        log(response.return_message)
      else
        # Received a non-successful http response.
        log("HTTP request failed: " + response.code.to_s)
      end
    end

    response = @request.run
    JSON.parse(response.response_body)[@connect_data_path]
  end

  private

    def initialize_options
      @options = QueryParams.sanitize(@options_hash)
      @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    end

    def index_query
      "SELECT * FROM #{@dataset_table_name}"
    end

    def options_query
      if @select.any?
        "SELECT cartodb_id FROM #{@dataset_table_name}"
      elsif @order.any?
        "SELECT * FROM #{@dataset_table_name}"
      end
    end

    def options_query
      to_select = @select.join(',') if @select.any?
      to_order  = @order.join(',')  if @order.any?

      filter =  if @select.any?
                  "SELECT #{to_select} FROM #{@dataset_table_name}"
                else
                  "SELECT * FROM #{@dataset_table_name}"
                end

      filter += " ORDER BY #{to_order}" if @order.any?
      filter
    end
end
