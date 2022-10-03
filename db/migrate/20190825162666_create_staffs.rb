class CreateStaffs < ActiveRecord::Migration[5.0]
  def change
    create_table :staffs do |t|
      t.string :name
      t.string :father
      t.string :education
      t.string :phone
      t.string :address
      t.string :cnic
      t.date :date_of_joining
      t.integer :yearly_increment
      t.integer :monthly_salary
      t.string :department
      t.integer :gender
      t.integer :advance_amount, default: 0
      t.boolean :terminated, default: false
      t.datetime :terminated_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.boolean :deleted,  default: false
      t.datetime :deleted_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end
  end
end
