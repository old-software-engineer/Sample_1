class CreateSigners < ActiveRecord::Migration[5.0]
  def change
    create_table :signers do |t|
      t.belongs_to :contract
      t.string   :name
      t.string   :email
      t.string   :phone, limit: 11
      t.string   :code
      t.integer  :status
      t.string   :slug
      t.string   :dial_code, default: '1'
      t.string   :country_code, default: 'ca'
      t.integer  :code_attempt_count, default: 0

      t.timestamps
    end
  end
end
