require 'typhoeus'
require 'uri'

class CartodbService
  include Filters::FilterSelect
  include Filters::FilterWhere
  include Filters::FilterWhereNot
  include Filters::FilterOrder

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
        # log("got a time out")
      elsif response.code == 0
        # Could not get an http response, something's wrong.
        # log(response.return_message)
      else
        # Received a non-successful http response.
        # log("HTTP request failed: " + response.code.to_s)
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
      # SELECT
      filter = Filters::FilterSelect.apply_select(@select, @dataset_table_name)

      # WHERE
      filter += " WHERE" if (@not_filter.present? || @filter.present?)
      filter += Filters::FilterWhere.apply_where(@filter) if @filter.present?

      # WHERE NOT
      filter += " AND" if (@not_filter.present? && @filter.present?)
      filter += Filters::FilterWhereNot.apply_where_not(@not_filter) if @not_filter.present?

      # ORDER
      filter += Filters::FilterOrder.apply_order(@order) if @order.present?

      # ToDo: Validate query structure
      filter
    end
end
