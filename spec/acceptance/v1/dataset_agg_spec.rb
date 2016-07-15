require 'acceptance_helper'

module V1
  describe 'Datasets AGG', type: :request do
    context 'Aggregation for specific dataset' do
      fixtures :datasets
      fixtures :service_settings

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

      let(:group_attr_1) { URI.encode(Oj.dump([{"statisticType": "max", "onStatisticField": "population", "outStatisticFieldName": "population" }])) }
      let(:group_attr_2) { URI.encode(Oj.dump([{"statisticType": "sum", "onStatisticField": "population", "outStatisticFieldName": "population" }])) }

      context 'Aggregation with fs params' do
        it 'Allows aggregate cartoDB data using fs by one attribute' do
          post "/query/#{dataset_id}?outFields=iso&where=iso in ('ESP','AUS')&groupByFieldsForStatistics=iso&outStatistics=#{group_attr_1}&orderByFields=iso ASC", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to               eq(2)
          expect(data[0]['iso']).to          eq('AUS')
          expect(json['fields']).to be_present
        end

        it 'Allows aggregate cartoDB data using fs by two attributes with order DESC' do
          post "/query/#{dataset_id}?outFields=iso,year&where=iso in ('ESP','AUS')&groupByFieldsForStatistics=iso,year&outStatistics=#{group_attr_2}&orderByFields=iso ASC, year DESC", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to             eq(7)
          expect(data[0]['iso']).to        eq('AUS')
          expect(data[0]['population']).to eq(1000) # 2x500
        end

        it 'Allows aggregate cartoDB data using fs by two attributes with order DESC' do
          post "/query/#{dataset_id}?sql=select iso,year,sum(population) as population from public.test_dataset_sebastian where iso in ('ESP','AUS') group by iso,year order by iso ASC,year DESC", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to             eq(7)
          expect(data[0]['iso']).to        eq('AUS')
          expect(data[0]['population']).to eq(1000) # 2x500
        end

        it 'Return error message for wrong params' do
          post "/query/#{dataset_id}?sql=select isoss,sum(population) as population from public.test_dataset_sebastian where iso in ('ESP','AUS') group by iso order by iso DESC", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data['error'][0]).to eq('column "isoss" does not exist')
        end
      end
    end
  end
end
