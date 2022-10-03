class CreateCrontests < ActiveRecord::Migration[5.2]
  def change
    create_table :crontests do |t|
      t.string :name

      t.timestamps
    end
  end
end
