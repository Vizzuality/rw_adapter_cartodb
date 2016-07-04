module Filters
  class Select
    def self.apply_select(select_params, dataset_table_name, aggr_func, aggr_by)
      to_select = if aggr_by.present? && aggr_func.present?
                    select_params = select_params.join(',').split(',').delete_if { |p| p.in? aggr_by.join(',').split(',') }

                    aggr_params = aggr_by.join(',').split(',').map { |p| "#{aggr_func}(#{p}::integer) as #{p}" }

                    (select_params << aggr_params).join(',')
                  else
                    select_params.join(',')
                  end

      filter = if select_params.present?
                 "SELECT #{to_select} FROM #{dataset_table_name}"
               else
                 "SELECT * FROM #{dataset_table_name}"
               end
      filter
    end
  end
end
