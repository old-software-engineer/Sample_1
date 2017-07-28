class ContractsController < ApplicationController
  before_action :authenticate_user!

    def index
      @account = current_user.account
      @contracts = @account.contracts
    end

    def new
      @account = current_user.account
      @contract = @account.contracts.build
      @templates = @account.templates
    end

    def edit
      @contract.template.fields.each do |field|
        @contract.contract_fields.build(field_id: field.id) if @contract.contract_fields.find_by_field_id(field.id).nil?
      end
    end

    def show_contract_signer
      @contract = @signer.contract unless @signer.nil?
      @html = @contract.render
      @signer.viewed! if !(@signer.signed? or @signer.unsigned?)
      @signer.log({status: :viewed, ip: request.remote_ip})

      respond_to do |format|
        format.html {render :show_contract_signer, :layout => "preview"}
        format.pdf {render :layout => false}
      end
    end

    def create_pdf
      @pdf = @contract.create_pdf
    end

    def create
      @contract = Contract.new(contract_params)
      content = @contract.template.try(:body)
      @contract.signers.each_with_index do |signer, index|
        content = content.gsub("[[SIGNER_NAME_#{index+1}]]", signer.name)
        content = content.gsub("[[SIGNER_PHONE_#{index+1}]]", "+#{signer.dial_code}#{signer.phone}")
        content = content.gsub("[[SIGNER_EMAIL_#{index+1}]]", signer.email)
      end
      @contract.update_attributes(:content => content)

      respond_to do |format|
        if @contract.save
          format.html { redirect_to edit_signme_account_contract_path(@account,@contract), notice: t("contracts.create.notice") }
        else
          format.html { render :new }
        end
      end
    end

    def update
      respond_to do |format|
        if @contract.update(contract_params)
          format.html { redirect_to edit_signme_account_contract_path(@account,@contract), notice: t("contracts.update.notice") }
          format.json { render :show, status: :ok, location: @contract }
        else
          @url = signme_account_contract_path(@account, @contract)
          format.html { render :edit }
          format.json { render json: @contract.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @contract.destroy
      respond_to do |format|
        format.html { redirect_to signme_account_contracts_path(@account), notice: t("contracts.destroy.notice") }
        format.json { head :no_content }
      end
    end

    def fields
      if params[:template_id] && user_signed_in?
        @contract = @account.contracts.build({template_id: params[:template_id]})
        @fields = {}

        @contract.template.fields.each do |h|
          @fields[h.attributes["id"]] = h.attributes["key"]
        end

        @contract.template.fields.each do |field|
          @contract.contract_fields.build(field_id: field.id)
        end
      end

      respond_to do |format|
        format.js {render :fields, status: :ok}
      end
    end

    def preview
      unless @contract.nil?
        @html = @contract.render
      end
      respond_to do |format|
        format.html {render :preview, layout: "preview"}
        format.js {render :preview, status: :ok}
      end
    end

    def editor_content
      @html = @contract.content || ""
      @url = signme_account_contract_path(@account, @contract)
      render partial: "/signme/contracts/content_form"
    end

    def request_signature
      @contract.unsigned!
      @contract.signers.each do |signer|
        signer.log({status: :sent, ip: request.remote_ip})
        signer.request_signature
      end
      respond_to do |format|
        format.html { redirect_to signme_account_contracts_path(@account), notice: t("contracts.request_signature.notice") }
        format.json { head :no_content }
      end
    end

    def request_code
      @signer.log({status: :request_code, ip: request.remote_ip})
      @signer.send_code

      render :json => t("contracts.request_code.notice").to_json
    end

    def request_code_call
     @signer.log({status: :request_code, ip: request.remote_ip})
     @signer.send_code_call

     render :json => t("accounts.request_code_call.notice").to_json
    end

    def download_pdf
      @signer ||= Signer.where(:slug => params[:signer]).first if params[:signer].present?
      @signer = Signer.where(:slug => params[:id]).first if params[:id].present? and !@signer.present?
      @signer.log({status: :downloaded, ip: request.remote_ip})
      respond_to do |format|
        format.html { redirect_to @signer.contract.url }
        format.json { head :no_content }
      end
    end

    def sign
      if (params[:sign] && params[:sign][:code]) and @signer.sign?(params[:sign][:code])
        @signer.log({status: :signed, ip: request.remote_ip})
        @signer.signed!
        @contract = @signer.contract
        if request.xhr?
          render json: {signed: true, redirect_path: (signme_contract_signer_url(@signer)),
                        :html => render_to_string(:partial => 'shared/logs',
                                                  :formats => "html",
                                                  :layout => false )
                       }.to_json
        else
          respond_to do |format|
            format.html { redirect_to signme_contract_signer_url(@signer), notice: 'All done! You will receive an email shortly with a link to download your copy of the contract. If there are other parties that need to still sign, you will receive the link once all parties involved have signed.' }
            format.json { render :show, status: :ok}
          end
        end
      else
        if request.xhr?
          render json: {signed: false, expired: @signer.code_expired?, count: @signer.remaining_code_attempts}.to_json
        else
          respond_to do |format|
            format.html { redirect_to signme_contract_signer_url(@signer), alert: 'Invalid code. Contract not signed.' }
            format.json { render json: @signer.errors, status: :unprocessable_entity }
          end
        end
      end
    end

    def not_authorized
      render :layout => false
    end

    def connect
      code = params[:code].to_s
      code = code.to_s.chars.each_slice(1).map { |a| a.join.to_i }.join(",")
      response = Twilio::TwiML::Response.new do |r|
        r.Say "Your Signature code is #{code}", :voice => 'alice', :loop => 2
      end
      render text: response.text
    end

    private

      def contract_params
        params.require(:signme_contract).permit(:account_id, :slug, :status, :title, :message, :template_id, :content, :language, signers_attributes: [:id, :name, :email, :phone, :country_code, :dial_code, :_destroy], contract_fields_attributes: [:id, :field_id, :value])
      end

      def set_account
        if params[:account_id]
          @account = Account.find(params[:account_id])
        elsif user_signed_in?
          @account = current_user.sign_me_account
        elsif @signer
          @account = @signer.contract.account
        end
      end

      def set_contract
        if params[:id]
          @contract = Contract.friendly.find(params[:id])
        end
      end

      def set_signer
        if params[:id]
          @signer = Signer.friendly.find(params[:id])
        end
      end

      def set_url
        @templates = @account.templates
        if params[:action] == 'edit'
          @url = signme_account_contract_path(@account, @contract)
        else
          @url = signme_account_contracts_path(@account)
        end
      end

      def validate_account
        if @account
          unless @account == current_user.sign_me_account
            redirect_to not_authorized_signme_account_contracts_path
          end
        end
      end
  end
