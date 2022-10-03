class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.references :item_type, foreign_key: true
      t.string :title
      t.string :code
      t.integer :minimum
      t.integer :optimal
      t.integer :maximun
      t.string :comment
      t.integer :status
      t.integer :purchase_type
      t.timestamps
    end
  end
end
