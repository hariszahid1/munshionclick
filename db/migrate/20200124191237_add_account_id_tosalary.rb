class AddAccountIdTosalary < ActiveRecord::Migration[5.0]
  def change
    add_reference :salaries, :account, foreign_key: true
  end
end
