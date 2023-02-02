class CreateDailyAttendance < ActiveRecord::Migration[6.1]
  def change
    create_table :daily_attendances do |t|
      t.datetime :check_in
      t.datetime :check_out
      t.string :total_time
      t.text :comment
      t.references :staff
      t.references :attendance

      t.timestamps
    end
  end
end
