class CreateAttendance < ActiveRecord::Migration[6.1]
  def change
    create_table :attendances do |t|
      t.datetime :date
      t.text :comment

      t.timestamps
    end
  end
end
