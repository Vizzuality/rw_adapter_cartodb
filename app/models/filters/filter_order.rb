module Filters::FilterOrder
  def self.apply_order(order_params)
    to_order = order_params.join(',')

    filter = if to_order.include?('-')
               " ORDER BY #{to_order.delete! '-'} DESC"
             else
               " ORDER BY #{to_order} ASC"
             end
    filter
  end
end