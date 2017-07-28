class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.integer  :user_id
      t.string   :role
      t.string   :status, default: 'trial_start'
      t.boolean  :reminder_sent, default: false
      t.string   :proactives_access_token
      t.timestamps
    end
  end
end
