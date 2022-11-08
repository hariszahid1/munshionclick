class CreateFollowUps < ActiveRecord::Migration[6.1]
  def change
    create_table :follow_ups do |t|
      t.string :reminder_type
      t.string :task_type
      t.string :priority
      t.integer :assigned_to_id
      t.integer :created_by
      t.datetime :date
      t.references :followable, polymorphic: true

      t.timestamps
    end
  end
end
