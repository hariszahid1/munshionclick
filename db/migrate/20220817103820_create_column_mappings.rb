class CreateColumnMappings < ActiveRecord::Migration[6.1]
  def change
    create_table :map_columns do |t|
      t.string :table_column
      t.string :mapping_column
      t.string :table_name

      t.timestamps
    end
  end
end
