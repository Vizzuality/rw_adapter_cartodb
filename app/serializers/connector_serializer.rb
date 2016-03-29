class ConnectorSerializer < ActiveModel::Serializer
  attributes :id, :connector_name, :provider, :format, :connector_url, :connector_path, :table_name, :rest_connector_params, :table_columns, :data

  def data
    object.data(@options[:query_filter])
  end
end