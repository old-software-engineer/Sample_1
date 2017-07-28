class Log < ApplicationRecord
  enum status: [:sent, :viewed, :request_code, :signed, :downloaded]
  belongs_to :signer
  belongs_to :contract

  def created_at_formatted
    if created_at > Time.now
      'yesterday'
    else
      created_at.strftime("%I:%M %P")
    end
  end
end
