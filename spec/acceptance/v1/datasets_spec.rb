require 'acceptance_helper'

module V1
  describe 'Datasets', type: :request do
    context 'For specific dataset' do
      fixtures :datasets

      let!(:dataset_id)  { Dataset.first.id }
      let!(:dataset_id2) { Dataset.second.id }
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
                             "id": "#{dataset_id2}",
                             "provider": "CartoDb",
                             "format": "JSON",
                             "name": "Carto test api",
                             "connector_url": "https://insights.cartodb.com/tables/cait_2_0_country_ghg_emissions_filtered/public/map"
                           }}}

      context 'Without params' do
        it 'Allows access cartoDB data with default limit 1' do
          post "/query/#{dataset_id}", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).not_to be_nil
          expect(data['pcpuid']).not_to     be_nil
          expect(data['the_geom']).to       be_present
          expect(json['fields']).to         be_present
          expect(json['data'].length).to    eq(1)
        end

        it 'Allows access cartoDB data with default limit 1 for tables url' do
          post "/query/#{dataset_id}", params: tables_params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).to  be(1)
          expect(json['fields']).to      be_present
          expect(json['data'].length).to eq(1)
        end
      end

      context 'With params' do
        it 'Allows access all available cartoDB data with limit all' do
          post "/query/#{dataset_id}?limit=all", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).not_to be_nil
          expect(data['pcpuid']).not_to     be_nil
          expect(data['the_geom']).to       be_present
          expect(json['fields']).to         be_present
          expect(json['data'].length).to    eq(5)
        end

        it 'Allows access cartoDB data with order ASC' do
          post "/query/#{dataset_id}?order[]=cartodb_id", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).to eq(1)
        end

        it 'Allows access cartoDB data with order DESC' do
          post "/query/#{dataset_id}?order[]=-cartodb_id", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).to eq(5)
        end

        it 'Allows access cartoDB data details with select and order' do
          post "/query/#{dataset_id}?select[]=cartodb_id,pcpuid&order[]=pcpuid", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).to   eq(5)
          expect(data['pcpuid']).not_to   be_nil
          expect(data['the_geom']).not_to be_present
        end

        it 'Allows access cartoDB data details with select, filter and order DESC' do
          post "/query/#{dataset_id}?select[]=cartodb_id,pcpuid&filter=(cartodb_id==1,2,4,5 <and> pcpuid><'350558'..'9506590')&order[]=-pcpuid", params: params

          data = json['data'][0]

          expect(status).to eq(200)
          expect(data['cartodb_id']).to   eq(1)
          expect(data['pcpuid']).to       eq('500001')
          expect(data['the_geom']).not_to be_present
        end

        it 'Allows access cartoDB data details with select, filter_not and order' do
          post "/query/#{dataset_id}?select[]=cartodb_id,pcpuid&filter_not=(cartodb_id>=4 <and> pcpuid><'500001'..'9506590')&order[]=pcpuid", params: params

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
          post "/query/#{dataset_id}?filter=(cartodb_id<<5)&filter_not=(cartodb_id==4 <and> pcpuid><'500001'..'9506590')&order[]=-cartodb_id&limit=2", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to               eq(2)
          expect(data[0]['cartodb_id']).to   eq(3)
          expect(data[0]['pcpuid']).not_to   be_nil
          expect(data[0]['the_geom']).not_to be_nil
          expect(data[1]['cartodb_id']).to   eq(2)
        end

        it 'Allows access cartoDB data details for all filters without select and order' do
          post "/query/#{dataset_id}?filter=(cartodb_id>=2)&filter_not=(cartodb_id==4 <and> pcpuid><'350659'..'9506590')&limit=3", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data[0]['cartodb_id']).to   eq(2)
          expect(data[0]['pcpuid']).not_to   be_nil
          expect(data[0]['the_geom']).not_to be_nil
          expect(data[1]['cartodb_id']).to   eq(5)
        end

        it 'Allows access cartoDB data details for all filters' do
          post "/query/#{dataset_id}?select[]=cartodb_id,pcpuid&filter=(cartodb_id<<5 <and> pcpuid>='350558')&filter_not=(cartodb_id==4 <and> pcpuid><'350640'..'9506590')&order[]=-pcpuid", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to             eq(1)
          expect(data[0]['cartodb_id']).to eq(2)
          expect(data[0]['pcpuid']).not_to be_nil
          expect(data[0]['the_geom']).to   be_nil
        end

        it 'Allows access cartoDB data with limit rows' do
          post "/query/#{dataset_id}?limit=2", params: params

          expect(status).to eq(200)
          expect(json['data'].length).to eq(2)
        end

        it 'Allows access cartoDB data with limit rows as array filter' do
          post "/query/#{dataset_id}?limit[]=3", params: params

          expect(status).to eq(200)
          expect(json['data'].length).to eq(3)
        end

        it 'Allows access cartoDB data details for all filters without select and order' do
          post "/query/#{dataset_id}?select[]=cartodb_id&filter=(cartodb_id>=1)&filter_not=(cartodb_id==4 <and> pcpuid><'500001'..'9506590')&order[]=-pcpuid&limit=2", params: params

          expect(status).to eq(200)
          expect(json['data'].length).to eq(2)
        end
      end
    end
  end
end
