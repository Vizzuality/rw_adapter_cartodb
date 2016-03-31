module Filters::FilterSelect
  def self.apply_select(select_params, dataset_table_name)
    to_select  = select_params.join(',')

    filter = if select_params.present?
               "SELECT #{to_select} FROM #{dataset_table_name}"
             else
               "SELECT * FROM #{dataset_table_name}"
             end
    filter
  end
end