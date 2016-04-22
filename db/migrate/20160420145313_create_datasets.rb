class CreateDatasets < ActiveRecord::Migration[5.0]
  def change
    create_table :datasets, id: :uuid do |t|
      t.jsonb   :data_columns, default: '{}'
      t.integer :data_horizon, default: 0

      t.timestamps
    end

    add_index :datasets, :data_columns, using: :gin
  end
end
