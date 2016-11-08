# frozen_string_literal: true
require 'uri'

class DatasetParams < Hash
  def initialize(params)
    params[:connector_url] ||= params[:connectorUrl]
    params[:table_name]    ||= params[:tableName]
    params[:data_path]     ||= params[:dataPath]
    params[:data_horizon]  ||= params[:dataHorizon]
    sanitized_params = {
      id: params[:id] || nil,
      name: params[:name] || nil,
      provider: params[:provider] || nil,
      format: params[:format] || nil,
      connector_url: params[:connector_url] || nil,
      data_path: params[:data_path] || 'rows',
      table_name: params[:table_name] ||= table_name_param(params[:connector_url]),
      data_horizon: params[:data_horizon] || nil,
      attributes_path: params[:attributes_path] || 'fields'
    }

    super(sanitized_params)
    merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

  def table_name_param(connector_url)
    if connector_url.include?('/tables/')
      URI(connector_url).path.split("/tables/")[1].split("/")[0]
    else
      URI.decode(connector_url).downcase.split('from ')[1].split(' ')[0]
    end
  end
end
