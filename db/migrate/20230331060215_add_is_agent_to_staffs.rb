class AddIsAgentToStaffs < ActiveRecord::Migration[6.1]
  def change
    add_column :staffs, :is_agent, :boolean, default: false, if_not_exists: true
  end
end
