class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.string :address
      t.string :home
      t.string :office
      t.string :mobile
      t.string :fax
      t.string :email
      t.string :comment
      t.integer :status
      t.references :country
      t.references :city
      t.references :sys_user

      t.timestamps
    end
  end
end
