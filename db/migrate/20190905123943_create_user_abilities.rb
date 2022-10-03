class CreateUserAbilities < ActiveRecord::Migration[5.0]
  def change
    create_table :user_abilities do |t|
      t.integer :roles_mask
      t.references :user, foreign_key: true

      t.timestamps
    end

  end
end
