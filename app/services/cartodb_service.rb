# frozen_string_literal: true
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
                     "?q=#{convert_query}"
                   else
                     "?q=#{index_query}"
                   end

    url = URI.encode(@connect_data_url[/[^\?]+/])
    if url.include?('/tables/')
      if url.include?('/u/')
        url = URI(url)
        url_sub  = url.path.split(/u|tables/)[1].gsub('/','')
        url_host = 'carto.com'
        url = "#{url.scheme}://#{url_sub}.#{url_host}/api/v2/sql"
      else
        url = URI(url)
        url = "#{url.scheme}://#{url.host}/api/v2/sql"
      end
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

    def to_method
      @sql.present? ? 'sql2SQL' : 'fs2SQL'
    end

    def sql_params
      @sql || index_query
    end

    def convert_query
      query_path  = ''
      query_path += "where=#{@where}&"                                           if @where.present?
      query_path += "outFields=#{@outFields}&"                                   if @outFields.present?
      query_path += "tableName=#{@dataset_table_name}&"                          if @dataset_table_name.present?
      query_path += "orderByFields=#{@orderByFields}&"                           if @orderByFields.present?
      query_path += "resultRecordCount=#{@resultRecordCount}&"                   if @resultRecordCount.present?
      query_path += "groupByFieldsForStatistics=#{@groupByFieldsForStatistics}&" if @groupByFieldsForStatistics.present?
      query_path += "outStatistics=#{@outStatistics}&"                           if @outStatistics.present?
      query_path += "statisticType=#{@statisticType}&"                           if @statisticType.present?
      sql_path    = "#{sql_params}"                                              if sql_params.present?

      filter  = QueryService.connect_to_query_service(to_method, query_path, sql_path)
      filter += Filters::Limit.apply_limit(@limit) if @limit.present? && !@limit.include?('all')
      filter
    end
end
