class CreateTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :templates do |t|
      t.string   :name
      t.belongs_to :account
      t.text :body

      t.timestamps
    end
  end
end
