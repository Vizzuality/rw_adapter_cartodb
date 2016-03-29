class DatasetParams < Hash
  def initialize(params)
    sanitized_params = {
      id: params[:id] || nil,
      connector_name: params[:connector_name] || nil,
      provider: params[:provider] || nil,
      format: params[:format] || nil,
      rest_connector_params: params[:rest_connector_params] || [],
      table_columns: params[:dataset_meta][:table_columns] || [],
      connector_url: params[:dataset_meta][:connector_url] || nil,
      connector_path: params[:dataset_meta][:connector_path] || nil,
      table_name: params[:dataset_meta][:table_name] || nil
    }

    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end
end
