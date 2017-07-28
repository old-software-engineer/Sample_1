class TemplatesController < ApplicationController
  before_action :authenticate_user!

  def index
    @account = current_user.account
    @templates = @account.templates
  end

  def edit
    @account = current_user.account
    @template = @account.templates.find(params[:id])
    @template.fields.new
  end

  def new
    @account = current_user.account
    @template = @account.templates.new
    @template.fields.new
  end

  def create
    @template = Template.new(template_params)
    respond_to do |format|
      if @template.save
        format.html { redirect_to edit_signme_account_template_path(@account, @template), notice: t("templates.create.notice") }
        format.json { render :show, status: :created, location: @template }
      else
        format.html { render :new }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to edit_signme_account_template_path(@account, @template), notice: t("templates.update.notice") }
        format.json { render :show, status: :ok, location: @template }
      else
        format.html { render :edit }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  def preview
    if params[:body]
      renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true)
      markdown = Redcarpet::Markdown.new(renderer, extensions = {})
      @html = markdown.render(params[:body]).gsub("<em>", "_").gsub("</em>", "_")
    end

    respond_to do |format|
      if params[:body]
        format.js {render :preview, status: :ok}
      else
        #format.js {render json: @template.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @template.destroy
    respond_to do |format|
      format.html { redirect_to signme_account_templates_path(@account), notice: t("templates.destroy.notice") }
      format.json { head :no_content }
    end
  end

  def validate_keys
    text_keys = params[:text].scan(/\{{(.*?)\}}/).flatten.map(&:downcase)
    fields =  params[:fields].split(",").map(&:downcase)
    if((text_keys - fields).empty? and (fields - text_keys).any?)
      text = t('templates.validate_keys.extra_fields_added_warning')
    elsif((text_keys - fields).any? and (fields - text_keys).empty?)
      text = t('templates.validate_keys.extra_keys_in_text_warning')
    elsif((text_keys - fields).empty? and (fields - text_keys).empty?)
      text = "success"
    end
    render json: text.to_json
  end

  private

    def template_params
      params.require(:signme_template).permit(:account_id, :name, :body, fields_attributes: [:id, :template_id, :key, :_destroy])
    end

    def set_account
      @account = current_user.sign_me_account
    end

    def set_template
      @template = Template.find(params[:id])
    end

    def set_url
      if params[:action] == 'edit' || params[:action] == 'update'
        @url = signme_account_template_path(@account, @template)
      else
        @url = signme_account_templates_path(@account)
      end
    end

end

