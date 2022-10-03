class CreateDepartments < ActiveRecord::Migration[5.0]
  def change
    create_table :departments do |t|
      t.string :code
      t.string :title
      t.text :comment
      t.integer :status

      t.timestamps
    end
  end
end
