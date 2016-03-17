class Connector < ApplicationRecord
  self.table_name = :rest_connectors

  FORMAT   = %w(JSON)
  PROVIDER = %w(CartoDb)

  has_many :connector_params
  has_one  :dataset

  def format_txt
    FORMAT[connector_format - 0]
  end

  def provider_txt
    PROVIDER[connector_provider - 0]
  end

  def data(options = {})
    get_data = CartodbService.new(connect_data_url, connect_data_path, dataset_table_name, options)
    get_data.connect_data
  end

  private

    def connect_data_path
      connector_path.split(/\s*,\s*/).first
    end

    def connect_data_url
      connector_url
    end

    def dataset_table_name
      dataset.table_name
    end
end
