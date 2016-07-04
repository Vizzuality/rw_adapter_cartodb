require 'curb'
require 'uri'
require 'oj'

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

    url = URI.encode(@connect_data_url[/[^\?]+/])
    if url.include?('/tables/')
      url = URI(url)
      url = "#{url.scheme}://#{url.host}/api/v2/sql"
    end
    url += query_to_run

    ConnectorService.connect_to_provider(url, @connect_data_path)
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
      filter = Filters::Select.apply_select(@select, @dataset_table_name, @aggr_func, @aggr_by)
      # WHERE
      filter += ' WHERE ' if @not_filter.present? || @filter.present?
      filter += Filters::FilterWhere.apply_where(@filter, nil) if @filter.present?
      # WHERE NOT
      filter += ' AND' if @not_filter.present? && @filter.present?
      filter += Filters::FilterWhere.apply_where(nil, @not_filter) if @not_filter.present?
      # GROUP BY
      filter += Filters::GroupBy.apply_group_by(@group) if @group.present?
      # ORDER
      filter += Filters::Order.apply_order(@order) if @order.present?
      # Limit
      filter += Filters::Limit.apply_limit(@limit) if @limit.present? && !@limit.include?('all')
      # TODO: Validate query structure
      filter
    end
end
