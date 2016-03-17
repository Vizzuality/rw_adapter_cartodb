class Dataset < ApplicationRecord
  self.table_name = :datasets

  belongs_to :connector, foreign_key: 'connector_id'
end
