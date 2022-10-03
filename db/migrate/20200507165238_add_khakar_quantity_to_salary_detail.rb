class AddKhakarQuantityToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :salary_details, :khakar_quanity, :integer
    add_column :salary_details, :khakar_remaning, :integer
    add_column :salary_details, :khakar_debit,  :integer
    add_column :salary_details, :khakar_wast,   :integer
    add_column :salary_details, :khakar_extra,   :integer
    add_column :salary_details, :khakar_credit, :integer
  end
end
