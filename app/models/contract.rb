class Contract < ApplicationRecord
  extend FriendlyId

  after_initialize :set_status, :if => :new_record?

  belongs_to :account
  belongs_to :template

  has_many :logs, dependent: :destroy
  has_many :signers, dependent: :destroy
  has_many :contract_fields, dependent: :destroy
  has_many :fields, through: :contract_fields

  accepts_nested_attributes_for :signers, allow_destroy: true
  accepts_nested_attributes_for :contract_fields

  enum status: [:draft, :unsigned, :signed]

  friendly_id :slug_candidates, use: :slugged

  validates_uniqueness_of :slug
  validates :account, :title, :template, presence: true

  def slug_candidates
    [
      SecureRandom.uuid,
      [SecureRandom.uuid, 1]
    ]
  end

  def owner
    account.user
  end

  def set_status
    self.status ||= :draft
  end

  def isSigned?
    status = true
    signers.each do |s|
      status = s.signed?
    end
    status
  end

  def render
    renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, extensions = {})
    content = self.content.present? ? self.content : ""
    html = markdown.render(content).gsub("<em>", "_").gsub("</em>", "_")
    html = html.gsub("[[/", "@A@[[/").gsub("/]]", "/]]@A@ ")
    words_array = html.split("@A@").select{|word| word[0..2]== "[[/"}

    words_array.each do |word|
      req = word.split("/")[1]
      html = html.gsub(word,eval(req).strftime("%a, %d %b %Y"))
    end
    html = html.gsub("[[OWNER]]", self.account.user.username).gsub("@A@", "")

    unless contract_fields.nil?
      contract_fields.each do |contract|
        html.gsub!(/{{(?i)#{contract.field.key}}}/, contract.value) if html.downcase["{{#{contract.field.key.downcase}}}"]
      end
    end
    html
  end

  def create_pdf signer
    @html = render
    controller = ActionController::Base.new
    @render = controller.render_to_string(template: 'signme/contracts/pdf_template', locals: { :@contract => self, :@html => @html}, layout: "pdf")
    kit = PDFKit.new(@render, :page_size => 'Letter')
    @pdf = kit.to_pdf
    @s3 = AWS::S3.new
    @bucket = @s3.buckets[ENV['AWS_BUCKET']]
    @obj = @bucket.objects[slug].write(@pdf, acl: :public_read , :server_side_encryption => :aes256)
    unless @obj.nil?
      self.url = @obj.public_url.to_s
      save
      SignerNotifier.send_pdf_signer(self, signer).deliver_now
    end

    @pdf
  end
end
