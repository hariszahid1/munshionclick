class AddIsReadInFollowUp < ActiveRecord::Migration[6.1]
  def change
    add_column :follow_ups, :is_read, :boolean, default: false, if_not_exists: true
    add_column :follow_ups, :is_complete, :boolean, default: false, if_not_exists: true
  end
end
