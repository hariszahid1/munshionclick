class CreateGates < ActiveRecord::Migration[5.2]
  def change
    create_table :gates do |t|
      t.datetime :pather_from
      t.datetime :pather_to
      t.datetime :kharkar_from
      t.datetime :kharkar_to
      t.datetime :bhari_from
      t.datetime :bhari_to
      t.datetime :jalai_from
      t.datetime :jalai_to
      t.datetime :nakasi_from
      t.datetime :nakasi_to
      t.text :comment
      t.decimal :pather_cost
      t.decimal :kharkar_cost
      t.decimal :jalai_cost
      t.decimal :nakasi_cost

      t.timestamps
    end
  end
end
