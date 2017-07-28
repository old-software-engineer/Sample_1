class CreateContractFields < ActiveRecord::Migration[5.0]
  def change
    create_table :contract_fields do |t|
      t.belongs_to :contract
      t.belongs_to :field
      t.string :value

      t.timestamps
    end
  end
end
