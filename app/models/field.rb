class Field < ApplicationRecord
  belongs_to :template
  has_many :contract_fields, dependent: :destroy
  has_many :contracts, through: :contract_fields

  validates :key, presence: true
  validate :field_key_uniq, on: :create
  validates_format_of :key,
                      with: /\A^[a-zA-Z0-9-_ ]+$\z/,
                      message: "can only contain letters, numbers, '-' and '_'"
  before_validation do
    key.upcase!
  end

  def field_key_uniq
    errors.add(:key, 'Field must have uniq keys in one template') if Signme::Field.where({key: key, template_id: template_id}).count > 0
  end
end
