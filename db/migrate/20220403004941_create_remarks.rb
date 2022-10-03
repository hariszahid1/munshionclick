class CreateRemarks < ActiveRecord::Migration[6.1]
  def change
    create_table :remarks do |t|
      t.integer :user
      t.text :body
      t.text :message
      t.text :comment
      t.string :remark_type
      t.references :remarkable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
