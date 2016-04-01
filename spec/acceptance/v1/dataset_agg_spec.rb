require 'acceptance_helper'

module V1
  describe 'Datasets AGG', type: :request do
    context 'Aggregation for specific dataset' do
      let!(:params) {{'dataset': {
                      'id': 29,
                      'connector_name': 'Carto test api countries update',
                      'provider': 'CartoDb',
                      'format': 'JSON',
                      'rest_connector_params': [],
                      'dataset_meta': {
                        'connector_url': 'https://simbiotica.cartodb.com/api/v2/sql?q=select * from public.test_dataset_sebastian',
                        'connector_path': 'rows',
                        'table_name': 'public.test_dataset_sebastian',
                        'table_columns': {
                          'iso': {
                            'type': 'string'
                          },
                          'name': {
                            'type': 'string'
                          },
                          'year': {
                            'type': 'string'
                          },
                          'the_geom': {
                            'type': 'geometry'
                          },
                          'cartodb_id': {
                            'type': 'number'
                          },
                          'population': {
                            'type': 'number'
                          },
                          'the_geom_webmercator': {
                            'type': 'geometry'
                          }
                        }
                      }
                    }}}

      let!(:dataset_id) { 29 }

      context 'Aggregation with params' do
        it 'Allows aggregate cartoDB data by one attribute' do
          post "/query/#{dataset_id}?select[]=iso,population&filter=(iso=='ESP','AUS')&aggr_by[]=iso&aggr_func=max&order[]=iso", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to      eq(2)
          expect(data[0]['iso']).to eq('AUS')
        end

        it 'Allows aggregate cartoDB data by two attributes with order DESC' do
          post "/query/#{dataset_id}?select[]=iso,population&filter=(iso=='ESP','AUS')&aggr_by[]=iso,year&aggr_func=sum&order[]=iso,-year", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to      eq(7)
          expect(data[0]['iso']).to eq('AUS')
          expect(data[0]['population']).to eq(1000) # 2x500
        end

        it 'Return error message for wrong params' do
          post "/query/#{dataset_id}?select[]=isoss,population&filter=(iso=='ESP','AUS')&aggr_by[]=iso&aggr_func=max&order[]=iso", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to      eq(1)
          expect(data['error'][0]).to eq('column "isoss" does not exist')
        end
      end
    end
  end
end
