class CreatePosSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :pos_settings do |t|
      t.string :name, unique: true, null: false
      t.string :display_name
      t.string :phone
      t.string :logo
      t.text :address

      t.timestamps
    end
  end
end
