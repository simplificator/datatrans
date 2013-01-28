#encoding: utf-8

require 'spec_helper'

describe Datatrans::Web::Transaction do
  before do
    @successful_response = {
      :status => "success",
      :returnCustomerCountry => "CHE",
      :sign => "95f3111123e628eab6469c636e0d3f06",
      :aliasCC => "70323122544311173",
      :maskedCC => "520000xxxxxx0007",
      :responseMessage => "Authorized",
      :useAlias => "yes",
      :expm => "12",
      :responseCode => "01",
      :sign2 => "a9571428be4d9d37b88988656984bfbf",
      :testOnly => "yes",
      :currency => "CHF",
      :amount => "1000",
      :hiddenMode => "yes",
      :expy => "15",
      :merchantId => "1100000000",
      :authorizationCode => "521029462",
      :uppTransactionId => "110808173520119430",
      :refno => "1",
      :uppMsgType => "web",
      :uppCustomerName => "",
      :pmethod => "ECA",
      :reqtype => "NOA",
      :uppCustomerEmail => "customer@email.com",
      :acqAuthorizationCode => "173520"
    }

    @failed_response = {
      :status => "error",
      :returnCustomerCountry => "CHE",
      :sign => "95f3123246e628eab6469c636e0d3f06",
      :aliasCC => "70323122544311173",
      :maskedCC => "520000xxxxxx0007",
      :errorMessage => "declined",
      :useAlias => "yes",
      :expm => "12",
      :errorCode => "1403",
      :testOnly => "yes",
      :currency => "CHF",
      :amount => "1000",
      :hiddenMode => "yes",
      :expy => "14",
      :merchantId => "1100000000",
      :errorDetail => "Declined",
      :uppTransactionId => "110808173951050102",
      :refno => "1",
      :uppMsgType => "web",
      :uppCustomerName => "",
      :pmethod => "ECA",
      :reqtype => "NOA",
      :uppCustomerEmail => "customer@email.com"
    }

    @valid_params = {
      :refno => 'ABCDEF',
      :amount => 1000,
      :currency => 'CHF',
      :uppCustomerEmail => 'customer@email.com'
      # also params from view helper needed
    }
  end

  context "rails form helper" do
    before do
      @transaction = Datatrans::Web::Transaction.new(@valid_params)
      @view = ActionView::Base.new
    end

    it "should generate valid form field string" do
      @view.datatrans_notification_request_hidden_fields(@transaction).should == "<input id=\"merchantId\" name=\"merchantId\" type=\"hidden\" value=\"1100000000\" /><input id=\"hiddenMode\" name=\"hiddenMode\" type=\"hidden\" value=\"yes\" /><input id=\"reqtype\" name=\"reqtype\" type=\"hidden\" value=\"NOA\" /><input id=\"amount\" name=\"amount\" type=\"hidden\" value=\"1000\" /><input id=\"currency\" name=\"currency\" type=\"hidden\" value=\"CHF\" /><input id=\"useAlias\" name=\"useAlias\" type=\"hidden\" value=\"yes\" /><input id=\"sign\" name=\"sign\" type=\"hidden\" value=\"0402fb3fba8c6fcb40df9b7756e7e637\" /><input id=\"refno\" name=\"refno\" type=\"hidden\" value=\"ABCDEF\" /><input id=\"uppCustomerDetails\" name=\"uppCustomerDetails\" type=\"hidden\" /><input id=\"uppCustomerEmail\" name=\"uppCustomerEmail\" type=\"hidden\" value=\"customer@email.com\" />"
    end
  end

  context "successful response" do
    before do
      Datatrans::Web::Transaction::AuthorizeResponse.any_instance.stub(:params).and_return(@successful_response)
    end

    context "process" do
      it "handles a valid datatrans authorize response" do
        @transaction = Datatrans::Web::Transaction.new(@valid_params)
        @transaction.authorize.should be_true
      end
    end
  end

  context "compromised response" do
    before do
      fake_response = @successful_response
      fake_response[:sign2] = 'invalid'
      Datatrans::Web::Transaction::AuthorizeResponse.any_instance.stub(:params).and_return(fake_response)
      @transaction = Datatrans::Web::Transaction.new(@valid_params)
    end

    it "raises an exception if sign2 is invalid" do
      expect {
        @transaction.authorize
      }.to raise_error(Datatrans::InvalidSignatureError)
    end
  end

  context "failed response" do
    before do
      Datatrans::Web::Transaction::AuthorizeResponse.any_instance.stub(:params).and_return(@failed_response)
      @transaction = Datatrans::Web::Transaction.new(@valid_params)
    end

    context "process" do
      it "handles a failed datatrans authorize response" do
        @transaction.authorize.should be_false
      end

      it "returns error details" do
        @transaction.authorize
        @transaction.error_code.length.should > 0
        @transaction.error_message.length.should > 0
        @transaction.error_detail.length.should > 0
      end
    end
  end
end