class CreatePdfTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :pdf_templates do |t|
      t.string :title
      t.string :table_name
      t.text :content
      t.text :comment
      t.string :method_name

      t.timestamps
    end
  end
end
