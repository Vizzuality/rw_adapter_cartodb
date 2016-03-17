require 'acceptance_helper'

module V1
  describe 'Datasets', type: :request do
    fixtures :rest_connectors
    fixtures :datasets

    context 'For datasets list' do
      it 'Allows access datasets list' do
        get '/datasets'

        expect(status).to eq(200)
        expect(json.length).to eq(2)
        expect(json[0]['connector_name']).to        eq('CartoDb test set')
        expect(json[0]['provider']).to              eq('CartoDb')
        expect(json[0]['format']).to                eq('JSON')
        expect(json[0]['dataset']['table_name']).to eq('carts_test_endoint')
      end
    end

    context 'For specific dataset' do
      let!(:dataset) { Connector.first }

      it 'Allows access dataset details' do
        get "/datasets/#{dataset.id}"

        data = json['data'][0]

        expect(status).to eq(200)
        expect(data['cartodb_id']).not_to be_nil
        expect(data['pcpuid']).not_to     be_nil
        expect(data['the_geom']).to       be_present
      end

      it 'Allows access dataset details with select and order' do
        get "/datasets/#{dataset.id}", { select: ['cartodb_id', 'pcpuid'] }, { order: 'pcpuid' }

        data = json['data'][0]

        expect(status).to eq(200)
        expect(data['cartodb_id']).to   eq(2)
        expect(data['pcpuid']).not_to   be_nil
        expect(data['the_geom']).not_to be_present
      end
    end
  end
end
