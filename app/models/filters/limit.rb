module Filters
  class Limit
    def self.apply_limit(order_params)
      to_order = order_params.is_a?(Array) ? order_params.join(',').split(',') : order_params.split(',')
      filter = ' Limit'

      order_attr = "#{to_order[0]}"
      filter += " #{order_attr}"
      filter
    end
  end
end
