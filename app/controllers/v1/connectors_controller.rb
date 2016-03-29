module V1
  class ConnectorsController < ApplicationController
    before_action :set_connector
    before_action :set_query_filter

    def show
      render json: @connector, serializer: ConnectorSerializer, query_filter: @query_filter, root: false
    end

    private

      def set_connector
        @connector = RestConnector.new(params)
      end

      def set_query_filter
        @query_filter = {}
        @query_filter['select'] = params[:select] if params[:select].present?
        @query_filter['order']  = params[:order]  if params[:order].present?
      end
  end
end
