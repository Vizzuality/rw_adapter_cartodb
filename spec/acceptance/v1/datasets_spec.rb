require 'acceptance_helper'

module V1
  describe 'Datasets', type: :request do
    fixtures :rest_connectors
    fixtures :datasets

    context 'For specific dataset' do
      let!(:params) {{'dataset': {
                      'id': 23,
                      'connector_name': 'Carto test api',
                      'provider': 'CartoDb',
                      'format': 'JSON',
                      'rest_connector_params': [],
                      'dataset_meta': {
                        'connector_url': 'https://rschumann.cartodb.com/api/v2/sql?q=select%20*%20from%20public.carts_test_endoint',
                        'connector_path': 'rows',
                        'table_name': 'public.carts_test_endoint',
                        'table_columns': {
                          'pcpuid': {
                            'type': 'string'
                          },
                          'the_geom': {
                            'type': 'geometry'
                          },
                          'cartodb_id': {
                            'type': 'number'
                          },
                          'the_geom_webmercator': {
                            'type': 'geometry'
                          }
                        }
                      }
                    }}}

      let!(:dataset_id) { 23 }

      it 'Allows access dataset details' do
        post "/query/#{dataset_id}", params

        data = json['data'][0]

        expect(status).to eq(200)
        expect(data['cartodb_id']).not_to be_nil
        expect(data['pcpuid']).not_to     be_nil
        expect(data['the_geom']).to       be_present
      end

      it 'Allows access dataset details with select and order' do
        post "/query/#{dataset_id}?select[]=cartodb_id&select[]=pcpuid&order[]=pcpuid", params

        data = json['data'][0]

        expect(status).to eq(200)
        expect(data['cartodb_id']).to   eq(5)
        expect(data['pcpuid']).not_to   be_nil
        expect(data['the_geom']).not_to be_present
      end
    end
  end
end
