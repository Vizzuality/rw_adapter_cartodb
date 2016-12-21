module V1
  class ConnectorsController < ApplicationController
    include ActionController::Live

    FLUSH_EVERY = 500

    before_action :disable_gc,       only:   :show
    before_action :set_connector,    except: :info
    before_action :set_query_filter, except: :info
    before_action :set_data,         only:   :show
    before_action :set_uri,          except: :info
    before_action :set_dataset,      only:   [:show, :update, :destroy]
    after_action  :enable_gc,        only:   :show

    def show
      render json: @connector, serializer: ConnectorSerializer, query_filter: @query_filter, root: false, uri: @uri, data: stream_data_array(@data)
    end

    def create
      begin
        @dataset = Dataset.new(meta_data_params)
        @dataset.save
        notify(@dataset.id, 'saved')
        render json: { success: true, message: "Dataset with id: #{@dataset.id} created" }, status: 201
      rescue
        notify(connector_params[:id])
        render json: { success: false, message: 'Error creating dataset' }, status: 422
      end
    end

    def update
      begin
        @dataset.update(meta_data_params)
        notify(@dataset.id, 'saved')
        render json: { success: true, message: 'Dataset updated' }, status: 200
      rescue
        notify(@dataset.id)
        render json: { success: false, message: 'Error updating dataset' }, status: 422
      end
    end

    def destroy
      @dataset.destroy
      begin
        Dataset.notifier(params[:id], 'deleted') if ServiceSetting.auth_token.present?
        render json: { message: 'Dataset deleted' }, status: 200
      rescue ActiveRecord::RecordNotDestroyed
        return render json: @dataset.erors, message: 'Dataset could not be deleted', status: 422
      end
    end

    def fields
      render json: @connector, serializer: ConnectorFieldsSerializer, root: false
    end

    private

      def set_connector
        @connector = RestConnector.new(params) if params[:dataset].present? || params[:connector].present?
      end

      def set_dataset
        @dataset = Dataset.find(params[:id])
      end

      def set_query_filter
        # For convert endpoint fs2SQL
        @query_filter = {}
        @query_filter['limit']                      = params[:limit]                      if params[:limit].present?
        @query_filter['outFields']                  = params[:outFields]                  if params[:outFields].present?
        @query_filter['orderByFields']              = params[:orderByFields]              if params[:orderByFields].present?
        @query_filter['resultRecordCount']          = params[:resultRecordCount]          if params[:resultRecordCount].present?
        @query_filter['where']                      = params[:where]                      if params[:where].present?
        @query_filter['tableName']                  = params[:tableName]                  if params[:tableName].present?
        @query_filter['groupByFieldsForStatistics'] = params[:groupByFieldsForStatistics] if params[:groupByFieldsForStatistics].present?
        @query_filter['outStatistics']              = params[:outStatistics]              if params[:outStatistics].present?
        @query_filter['statisticType']              = params[:statisticType]              if params[:statisticType].present?
        # For convert endpoint sql2SQL
        @query_filter['sql']                        = params[:sql]                        if params[:sql].present?
        # Geostore
        @query_filter['geostore']                   = params[:geostore]                   if params[:geostore].present?
      end

      def set_data
        @data = @connector.data(@query_filter)
      end

      def set_uri
        @uri = {}
        @uri['api_gateway_url'] = Service::SERVICE_URL
        @uri['full_path']       = request.fullpath
      end

      def notify(dataset_id, status=nil)
        Dataset.notifier(dataset_id, status) if ServiceSetting.auth_token.present?
      end

      def meta_data_params
        @connector.recive_dataset_meta[:dataset]
      end

      def connector_params
        params.require(:connector).permit(:id, :connector_url, :attributes_path, :table_name)
      end

      def clone_url
        data = {}
        data['httpMethod'] = 'POST'
        data['url']        = "#{URI.parse(clone_uri)}"
        data['body']       = body_params
        data
      end

      def uri
        "#{@uri['api_gateway_url']}#{@uri['full_path']}"
      end

      def clone_uri
        "#{@uri['api_gateway_url']}/datasets/#{@dataset.id}/clone"
      end

      def body_params
        {
          "dataset" => {
            "datasetUrl" => "#{URI.parse(uri)}"
          },
          "application" => ["your", "apps"]
        }
      end

      def stream_data_array(data)
        return data if Rails.env.test?
        headers["Content-Disposition"] = 'attachment'
        headers["Content-Type"]        = 'application/json; charset=utf-8'
        headers["Content-Encoding"]    = 'deflate'

        deflate = Zlib::Deflate.new

        buffer = "{\n"
        buffer << '"cloneUrl": '
        buffer << JSON.pretty_generate(clone_url)
        buffer << ",\n"
        buffer << '"data": '
        buffer << "[\n  "

        data.each_with_index do |object, i|
          buffer << ",\n  " unless i.zero?
          buffer << JSON.pretty_generate(object, depth: 1)

          if (i % FLUSH_EVERY).zero?
            write(deflate, buffer)
            buffer = ""
          end
        end

        buffer << "\n]\n}\n"

        write(deflate, buffer)
        write(deflate, nil) # Flush deflate.
        response.stream.close
      end

      def write(deflate, data)
        deflated = deflate.deflate(data)
        response.stream.write(deflated)
      end

      def disable_gc
        GC.disable
      end

      def enable_gc
        ActiveRecord::Base.connection.close
        response.stream.close
        GC.start(full_mark: false, immediate_sweep: false)
      end
  end
end
