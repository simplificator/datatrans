require 'spec_helper'

describe Datatrans::WEB::Transaction do
  before do
    @valid_params = {
      :refno => 'ABCDEF',
      :amount => 1000,
      :currency => 'CHF',
      :aliasCC => '3784982984234',
      :expm => 12,
      :expy => 15,
      :uppCustomerEmail => 'customer@email.com'
    }
  end
  
  context "rails form helper" do
    before do
      @transaction = Datatrans::WEB::Transaction.new(@valid_params)
      @view = ActionView::Base.new
    end
    
    it "should generate valid form field string" do
      @view.datatrans_notification_request_hidden_fields(@transaction).should == "<input id=\"merchantId\" name=\"merchantId\" type=\"hidden\" value=\"1100000000\" /><input id=\"hiddenMode\" name=\"hiddenMode\" type=\"hidden\" value=\"Yes\" /><input id=\"reqtype\" name=\"reqtype\" type=\"hidden\" value=\"NOA\" /><input id=\"amount\" name=\"amount\" type=\"hidden\" value=\"1000\" /><input id=\"currency\" name=\"currency\" type=\"hidden\" value=\"CHF\" /><input id=\"useAlias\" name=\"useAlias\" type=\"hidden\" value=\"Yes\" /><input id=\"sign\" name=\"sign\" type=\"hidden\" value=\"0402fb3fba8c6fcb40df9b7756e7e637\" /><input id=\"refno\" name=\"refno\" type=\"hidden\" value=\"ABCDEF\" /><input id=\"uppCustomerName\" name=\"uppCustomerName\" type=\"hidden\" /><input id=\"uppCustomerEmail\" name=\"uppCustomerEmail\" type=\"hidden\" value=\"customer@email.com\" />"
    end
  end
  
  context "successful response" do
    
  end
  
  context "failed response" do
    
  end
end