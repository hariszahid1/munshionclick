class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.text :message
      t.integer :assigned_to_id
      t.integer :created_by

      t.references :notable, polymorphic: true

      t.timestamps
    end
  end
end
