class AddedCommentsColumnInFollowUps < ActiveRecord::Migration[6.1]
  def up
    add_column :follow_ups, :comment, :text
  end

  def down
    remove_column :follow_ups, :comment, :text
  end
end
