class CreateContracts < ActiveRecord::Migration[5.0]
  def change
    create_table :contracts do |t|
      t.belongs_to :account
      t.string   :slug
      t.integer  :status
      t.string   :url
      t.string   :title
      t.text     :message
      t.belongs_to :template
      t.text     :content
      t.string   :language

      t.timestamps
    end
  end
end
