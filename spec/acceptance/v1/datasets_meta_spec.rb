require 'acceptance_helper'

module V1
  describe 'Datasets Meta', type: :request do
    context 'Create and update meta data for specific dataset' do
      fixtures :datasets
      let!(:params) {{"dataset": {
                      "id": "9b98340b-5f51-444a-bed7-2c5bf7a1894c",
                      "provider": "CartoDb",
                      "format": "JSON",
                      "name": "Carto test api",
                      "data_path": "rows",
                      "attributes_path": "fields",
                      "connector_url": "https://rschumann.cartodb.com/api/v2/sql?q=select%20*%20from%20public.carts_test_endoint",
                      "table_name": "public.carts_test_endoint",
                    }, "connector": {"id": "9b98340b-5f51-444a-bed7-2c5bf7a1894c",
                       "connector_url": "https://rschumann.cartodb.com/api/v2/sql?q=select%20*%20from%20public.carts_test_endoint",
                       "attributes_path": "fields"}}}

      let!(:params_failed) {{"dataset": {
                            "id": "9b98340b-5f51-444a-bed7-2c5bf7a1894b",
                            "provider": "CartoDb",
                            "format": "JSON",
                            "name": "Carto test api",
                            "data_path": "rows",
                            "attributes_path": "fields",
                            "connector_url": "https://rschumann.cartodb.com/api/v2/sql?q=select%20*%20from%20public.carts_test_endoin",
                            "table_name": "public.carts_test_endoint",
                          }, "connector": {"id": "9b98340b-5f51-444a-bed7-2c5bf7a1894b",
                             "connector_url": "https://rschumann.cartodb.com/api/v2/sql?q=select%20*%20from%20public.carts_test_endoin",
                             "attributes_path": "fields"}}}

      context 'Without data_attributes params' do
        it 'Allows access cartoDB data and save data attributes to db' do
          post "/datasets", params: params

          expect(status).to eq(201)
          expect(json['success']).to eq(true)
          expect(Dataset.find('9b98340b-5f51-444a-bed7-2c5bf7a1894c').data_columns).to be_present
        end

        it 'If dataset_url failed' do
          post "/datasets", params: params_failed

          expect(status).to eq(422)
          expect(json['success']).to eq(false)
          expect(Dataset.where(id: '9b98340b-5f51-444a-bed7-2c5bf7a1894b')).to be_empty
        end
      end
    end
  end
end
