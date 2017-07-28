class Account < ApplicationRecord
  has_many :templates
  has_many :contracts

  validates :user_id, presence: true

  # after_create :send_email_start_trial

  def send_email_start_trial
    SignerNotifier.trial_start(self, 'papaye').deliver_now
  end

  def user
    @user ||= User.find_by(proactives_access_token)
  end

  def username
    "username"
  end

  def email
    user.email
  end

  def isAdmin?
    user.admin? ? 'admin' : 'regular'
  end

  def isAdmin_formatted?
    user.admin? ? 'admin' : 'regular'
  end

  def logs
    contract = contracts
    Signme::Log.where(contract_id: contract)
  end

  def account
    self
  end

  def avatar

  end 
end
