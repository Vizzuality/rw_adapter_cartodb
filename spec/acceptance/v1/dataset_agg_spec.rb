require 'acceptance_helper'

module V1
  describe 'Datasets AGG', type: :request do
    context 'Aggregation for specific dataset' do
      fixtures :datasets

      let!(:dataset_id) { Dataset.last.id }
      let!(:params) {{"dataset": {
                      "id": "#{dataset_id}",
                      "provider": "CartoDb",
                      "format": "JSON",
                      "name": "Carto test api",
                      "connector_url": "https://simbiotica.cartodb.com/api/v2/sql?q=select * from public.test_dataset_sebastian where cartodb_id in (2, 3)"
                    }}}

      let!(:tables_params) {{"dataset": {
                             "id": "#{dataset_id}",
                             "provider": "CartoDb",
                             "format": "JSON",
                             "name": "Carto test api table endpoint",
                             "connector_url": "https://insights.cartodb.com/tables/cait_2_0_country_ghg_emissions_filtered/public/map"
                           }}}

      context 'Aggregation with params' do
        it 'Allows aggregate cartoDB data by one attribute' do
          post "/query/#{dataset_id}?select[]=iso,population&filter=(iso=='ESP','AUS')&aggr_by[]=population&aggr_func=max&group_by=iso&order[]=iso", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to               eq(2)
          expect(data[0]['iso']).to          eq('AUS')
          expect(json['fields']).to be_present
        end

        it 'Allows aggregate cartoDB data by two attributes with order DESC' do
          post "/query/#{dataset_id}?select[]=iso,population,year&filter=(iso=='ESP','AUS')&aggr_by[]=population&aggr_func=sum&group_by[]=iso,year&order[]=iso,-year", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to             eq(7)
          expect(data[0]['iso']).to        eq('AUS')
          expect(data[0]['population']).to eq(1000) # 2x500
        end

        it 'Return error message for wrong params' do
          post "/query/#{dataset_id}?select[]=isoss,population&filter=(iso=='ESP','AUS')&aggr_by[]=population&aggr_func=max&group_by=iso&order[]=iso", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data['error'][0]).to eq('column "isoss" does not exist')
        end
      end
    end
  end
end
