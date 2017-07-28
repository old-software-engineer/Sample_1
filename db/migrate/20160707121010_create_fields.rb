class CreateFields < ActiveRecord::Migration[5.0]
  def change
    create_table :fields do |t|
      t.belongs_to :template
      t.string :key

      t.timestamps
    end
  end
end
