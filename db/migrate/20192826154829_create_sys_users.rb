class CreateSysUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :sys_users do |t|
      t.string :code
      t.string :cnic
      t.string :name
      t.references :user_type, foreign_key: true
      t.integer :user_group
      t.integer :status
      t.string :occupation
      t.integer :credit_status
      t.integer :credit_limit
      t.integer :opening_balance
      
      t.timestamps
    end
  end
end
