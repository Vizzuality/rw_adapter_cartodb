require 'acceptance_helper'

module V1
  describe 'Datasets', type: :request do
    fixtures :rest_connectors
    fixtures :datasets

    context 'For specific dataset' do
      let!(:dataset) { RestConnector.first }

      it 'Allows access dataset details' do
        get "/query/#{dataset.id}"

        data = json['data'][0]

        expect(status).to eq(200)
        expect(data['cartodb_id']).not_to be_nil
        expect(data['pcpuid']).not_to     be_nil
        expect(data['the_geom']).to       be_present
      end

      it 'Allows access dataset details with select and order' do
        get "/query/#{dataset.id}", { select: ['cartodb_id', 'pcpuid'] }, { order: 'pcpuid' }

        data = json['data'][0]

        expect(status).to eq(200)
        expect(data['cartodb_id']).to   eq(2)
        expect(data['pcpuid']).not_to   be_nil
        expect(data['the_geom']).not_to be_present
      end
    end
  end
end
