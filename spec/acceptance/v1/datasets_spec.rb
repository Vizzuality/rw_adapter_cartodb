require 'acceptance_helper'

module V1
  describe 'Datasets', type: :request do
    context 'For specific dataset' do
      fixtures :datasets
      fixtures :service_settings

      let!(:dataset_id)   { Dataset.first.id }
      let!(:dataset_id_2) { Dataset.second.id }

      let!(:params) {{"dataset": {
                      "id": "#{dataset_id}",
                      "provider": "CartoDb",
                      "format": "JSON",
                      "name": "Carto test api",
                      "attributes_path": "fields",
                      "connector_url": "https://rschumann.cartodb.com/api/v2/sql?q=select%20*%20from%20public.carts_test_endoint",
                      "table_name": "public.carts_test_endoint",
                    }}}

      let!(:tables_params) {{"dataset": {
                             "id": "#{dataset_id_2}",
                             "provider": "CartoDb",
                             "format": "JSON",
                             "name": "Carto test api",
                             "connector_url": "https://insights.cartodb.com/tables/cait_2_0_country_ghg_emissions_filtered/public/map"
                           }}}

      context 'Without params' do
        it 'Allows access cartoDB data with default limit 1' do
          post "/query/#{dataset_id}", params: params

          data = json['attributes']['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb-id']).not_to be_nil
          expect(data['pcpuid']).not_to     be_nil
          expect(data['the-geom']).to       be_present
          expect(json['attributes']['data'].length).to    eq(1)
        end

        it 'Allows access cartoDB data with default limit 1 for tables url' do
          post "/query/#{dataset_id}", params: tables_params

          data = json['attributes']['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb-id']).to  be(1)
          expect(json['attributes']['data'].length).to eq(1)
        end
      end

      context 'With params' do
        it 'Allows access all available cartoDB data with limit all' do
          post "/query/#{dataset_id}?limit=all", params: params

          data = json['attributes']['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb-id']).not_to be_nil
          expect(data['pcpuid']).not_to     be_nil
          expect(data['the-geom']).to       be_present
          expect(json['attributes']['data'].length).to    eq(5)
        end

        it 'Allows access cartoDB data with order ASC' do
          post "/query/#{dataset_id}?sql=select * from public.carts_test_endoint order by cartodb_id ASC", params: params

          data = json['attributes']['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb-id']).to eq(1)
        end

        it 'Allows access cartoDB data with order DESC' do
          post "/query/#{dataset_id}?sql=select * from public.carts_test_endoint order by cartodb_id DESC", params: params

          data = json['attributes']['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb-id']).to eq(5)
        end

        it 'Allows access cartoDB data details with select and order using fs' do
          post "/query/#{dataset_id}?outFields=cartodb_id,pcpuid&orderByFields=pcpuid ASC", params: params

          data = json['attributes']['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb-id']).to   eq(5)
          expect(data['pcpuid']).not_to   be_nil
          expect(data['the-geom']).not_to be_present
        end

        it 'Allows access cartoDB data details with select, filter and order DESC' do
          post "/query/#{dataset_id}?sql=select cartodb_id,pcpuid from public.carts_test_endoint where cartodb_id in (1,2,4,5) and pcpuid between '350558' and '9506590' order by pcpuid DESC", params: params

          data = json['attributes']['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb-id']).to   eq(1)
          expect(data['pcpuid']).to       eq('500001')
          expect(data['the-geom']).not_to be_present
        end

        it 'Allows access cartoDB data details with select, filter_not and order' do
          post "/query/#{dataset_id}?sql=select cartodb_id,pcpuid from public.carts_test_endoint where cartodb_id != 4 and pcpuid not between '500001' and '9506590' order by pcpuid ASC", params: params

          data = json['attributes']['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb-id']).to   eq(5)
          expect(data['pcpuid']).not_to   be_nil
          expect(data['the-geom']).not_to be_present
        end

        it 'Allows access cartoDB data details for all filters using fs' do
          post "/query/#{dataset_id}?outFields=cartodb_id,pcpuid&where=cartodb_id < 5 and pcpuid >= '350558' and cartodb_id != 4 and pcpuid not between '350640' and '9506590'&orderByFields=pcpuid DESC", params: params

          data = json['attributes']['data']

          expect(status).to eq(200)
          expect(data.size).to             eq(1)
          expect(data[0]['cartodb-id']).to eq(2)
          expect(data[0]['pcpuid']).not_to be_nil
          expect(data[0]['the-geom']).to   be_nil
        end

        it 'Allows access cartoDB data with limit rows' do
          post "/query/#{dataset_id}?limit=2", params: params

          expect(status).to eq(200)
          expect(json['attributes']['data'].length).to eq(2)
        end

        it 'Allows access cartoDB data with limit rows as array filter' do
          post "/query/#{dataset_id}?limit[]=3", params: params

          expect(status).to eq(200)
          expect(json['attributes']['data'].length).to eq(3)
        end
      end

      context 'For fields info' do
        it 'Allows access Json data with default limit 1' do
          post "/fields/#{dataset_id}", params: params

          expect(status).to eq(200)
          expect(json['attributes']['fields']).to         be_present
          expect(json['attributes']['table-name']).not_to eq('data')
        end
      end
    end
  end
end
