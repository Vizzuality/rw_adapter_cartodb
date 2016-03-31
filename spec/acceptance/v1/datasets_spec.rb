require 'acceptance_helper'

module V1
  describe 'Datasets', type: :request do
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

      context 'Without params' do
        it 'Allows access cartoDB data' do
          # raw_response_file = File.new('spec/support/response/1.json').read
          # stub_request(:any, /rschumann.cartodb.com/).to_return(body: raw_response_file)
          post "/query/#{dataset_id}", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).not_to be_nil
          expect(data['pcpuid']).not_to     be_nil
          expect(data['the_geom']).to       be_present
        end
      end

      context 'With params' do
        it 'Allows access cartoDB data details with select and order' do
          post "/query/#{dataset_id}?select[]=cartodb_id&select[]=pcpuid&order[]=pcpuid", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).to   eq(5)
          expect(data['pcpuid']).not_to   be_nil
          expect(data['the_geom']).not_to be_present
        end

        it 'Allows access cartoDB data details with select, filter and order DESC' do
          post "/query/#{dataset_id}?select[]=cartodb_id&select[]=pcpuid&filter=(cartodb_id==1,2,4,5 <and> pcpuid><'350558'..'9506590')&order[]=-pcpuid", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).to   eq(1)
          expect(data['pcpuid']).to       eq('500001')
          expect(data['the_geom']).not_to be_present
        end

        it 'Allows access cartoDB data details with select, filter_not and order' do
          post "/query/#{dataset_id}?select[]=cartodb_id&select[]=pcpuid&filter_not=(cartodb_id>=4 <and> pcpuid><'500001'..'9506590')&order[]=pcpuid", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).to   eq(2)
          expect(data['pcpuid']).not_to   be_nil
          expect(data['the_geom']).not_to be_present
        end

        it 'Allows access cartoDB data details with select, all filters and order DESC' do
          post "/query/#{dataset_id}?select[]=cartodb_id&filter=(cartodb_id==5)&filter_not=(cartodb_id==4 <and> pcpuid><'500001'..'9506590')&order[]=-pcpuid", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).to   eq(5)
          expect(data['pcpuid']).not_to   be_present
          expect(data['the_geom']).not_to be_present
        end

        it 'Allows access cartoDB data details for all filters, order and without select' do
          post "/query/#{dataset_id}?filter=(cartodb_id<<5)&filter_not=(cartodb_id==4 <and> pcpuid><'500001'..'9506590')&order[]=-cartodb_id", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to               eq(2)
          expect(data[0]['cartodb_id']).to   eq(3)
          expect(data[0]['pcpuid']).not_to   be_nil
          expect(data[0]['the_geom']).not_to be_nil
          expect(data[1]['cartodb_id']).to   eq(2)
        end

        it 'Allows access cartoDB data details for all filters without select and order' do
          post "/query/#{dataset_id}?filter=(cartodb_id>=3)&filter_not=(cartodb_id==4 <and> pcpuid><'500001'..'9506590')", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data[0]['cartodb_id']).to   eq(3)
          expect(data[0]['pcpuid']).not_to   be_nil
          expect(data[0]['the_geom']).not_to be_nil
          expect(data[1]['cartodb_id']).to   eq(5)
        end
      end
    end
  end
end
