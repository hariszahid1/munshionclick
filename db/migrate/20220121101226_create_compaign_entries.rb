class CreateCompaignEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :compaign_entries do |t|
      t.string :name
      t.string :phone
      t.string :mobile
      t.string :email
      t.text :comment
      t.references :compaign
      t.timestamps
    end
  end
end
