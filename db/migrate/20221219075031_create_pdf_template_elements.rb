class CreatePdfTemplateElements < ActiveRecord::Migration[6.1]
  def change
    create_table :pdf_template_elements do |t|
      t.string :title
      t.references :pdf_template
      t.text :content
      t.text :comment

      t.timestamps
    end
  end
end
