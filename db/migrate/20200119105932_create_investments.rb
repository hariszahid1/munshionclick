class CreateInvestments < ActiveRecord::Migration[5.0]
  def change
    create_table :investments do |t|
      t.integer :invest
      t.text :comment

      t.timestamps
    end
  end
end
