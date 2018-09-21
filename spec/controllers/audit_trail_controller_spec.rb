require 'rails_helper'

describe AuditTrailController do

  include FileHelpers
  include UserAccountHelpers
  
  describe "audit trail access as system admin" do
  	
    before :all do
      ua_create
      AuditTrail.delete_all
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "I1", version: "1", event: 1, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "I2", version: "1", event: 1, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "T1", version: "1", event: 1, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "T2", version: "2", event: 1, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "T3", version: "3", event: 1, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "T1", version: "1", event: 2, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "T2", version: "2", event: 2, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "T3", version: "3", event: 2, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "T1", version: "1", event: 3, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "T2", version: "2", event: 3, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "T3", version: "3", event: 3, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "", version: "", event: 4, description: "Login")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", identifier: "", version: "", event: 4, description: "Logout")
      ar = AuditTrail.create(date_time: Time.now, user: "user2@example.com", identifier: "", version: "", event: 4, description: "Login")
      ar = AuditTrail.create(date_time: Time.now, user: "user2@example.com", identifier: "", version: "", event: 4, description: "Logout")
    end
    
    after :all do
      ua_destroy
      AuditTrail.delete_all
    end
    
    before :each do
      login_with_system_admin_access
      @user_audit = User.create(:email => "user@assero.co.uk", :password => "Changeme1%")
    end

    after :each do
      @user_audit.destroy
    end

    it "index" do
    	user_count = User.all.count
      get :index
      expect(assigns(:users).count).to eq(user_count)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(16) # +1
      expect(response).to render_template("index")
    end

    it "search audit trail - event user" do
      user_count = User.all.count
      put :search, {id: @user_audit.id, :audit_trail => {:user =>"", :identifier => "", :event =>"4"}}
      expect(assigns(:users).count).to eq(user_count)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(5) # +1
      expect(response).to render_template("index")
    end

    it "search audit trail - event create" do
      user_count = User.all.count
      put :search, {id: @user_audit.id, :audit_trail => {:user =>"", :identifier => "", :event =>"1"}}
      expect(assigns(:users).count).to eq(user_count)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(5)
      expect(response).to render_template("index")
    end

    it "search audit trail - event delete" do
      user_count = User.all.count
      put :search, {id: @user_audit.id, :audit_trail => {:user =>"", :identifier => "", :event =>"3"}}
      expect(assigns(:users).count).to eq(user_count)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(3)
      expect(response).to render_template("index")
    end

    it "search audit trail - identifier" do
      user_count = User.all.count
      put :search, {id: @user_audit.id, :audit_trail => {:user =>"", :identifier => "T3", :event =>"0"}}
      expect(assigns(:users).count).to eq(user_count)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(3)
      expect(response).to render_template("index")
    end

    it "export_csv" do
      get :export_csv
    end

  end

  describe "Reader User" do
    
    before :all do
      AuditTrail.delete_all
      ua_create
    end
    
    after :all do
      ua_destroy
    end
    
    before :each do
      login_with_read_access
    end

    it "index" do
      get :index
      expect(response).to redirect_to("/")
    end

    it 'search' do
      user = User.create :email => "fred@example.com", :password => "changeme" 
      put :search, {id: user.id, :audit_trail => {:user =>"", :identifier => "T10", :event =>"0"}}
      expect(response).to redirect_to("/")
    end

  end 
    
  describe "Unauthorized User" do
    
    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'search' do
      user = User.create :email => "fred@example.com", :password => "changeme" 
      put :search, {id: user.id, :audit_trail => {:user =>"", :identifier => "T10", :event =>"0"}}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end