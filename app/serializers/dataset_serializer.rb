class DatasetSerializer < ActiveModel::Serializer
  attributes :table_name, :table_columns, :row_count
end
