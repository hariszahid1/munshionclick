class AddPatherKhakarWastToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :salary_details, :pather_khakar_wast, :integer
  end
end
