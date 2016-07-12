require 'curb'
require 'uri'
require 'oj'

class QueryService
  class << self
    def connect_to_query_service(method, query_params=nil, sql_params=nil)
      url = if method.include?('fs2SQL')
              URI.decode("#{ServiceSetting.gateway_url}/convert/fs2SQL?#{query_params}")
            else
              URI.decode("#{ServiceSetting.gateway_url}/convert/checkSQL?sql=#{sql_params}")
            end

      @c = Curl::Easy.http_get(URI.escape(url)) do |curl|
        curl.headers['Accept']         = 'application/json'
        curl.headers['Content-Type']   = 'application/json'
        curl.headers['authentication'] = ServiceSetting.auth_token if ServiceSetting.auth_token.present?
      end
      @c.perform

      Oj.load(@c.body_str.force_encoding(Encoding::UTF_8))['data']['attributes']['query'] || Oj.load(@c.body_str.force_encoding(Encoding::UTF_8))
    end
  end
end
