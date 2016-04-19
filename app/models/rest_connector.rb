class RestConnector
  include ActiveModel::Serialization
  attr_reader :id, :connector_name, :provider, :format, :connector_url, :connector_path, :table_name, :data_attributes

  def initialize(params)
    @dataset_params = params[:dataset]
    initialize_options
  end

  def data(options = {})
    get_data = CartodbService.new(@connector_url, @connector_path, @table_name, options)
    get_data.connect_data
  end

  private

    def initialize_options
      @options = DatasetParams.sanitize(@dataset_params)
      @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    end
end
