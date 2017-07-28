class CreateLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :logs do |t|
      t.belongs_to :signer
      t.belongs_to :contract
      t.string :ip
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
