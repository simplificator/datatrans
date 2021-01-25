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

    @successful_swisspost_response = @successful_response.merge({
        :pmethod => "PFC",
        :txtEp2TrxID => "7777777000000001",
        :responseMessage => "YellowPay transaction Ok"
    })

    @canceled_response = @successful_response.merge({
      status: "cancel",
    })

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
      @transaction = Datatrans::Web::Transaction.new(@datatrans, @valid_params)
      @view = ActionView::Base.new
    end

    it "should generate valid form field string" do
      expect(@view.datatrans_notification_request_hidden_fields(@datatrans, @transaction)).to eq "<input type=\"hidden\" name=\"merchantId\" id=\"merchantId\" value=\"1100000000\" /><input type=\"hidden\" name=\"hiddenMode\" id=\"hiddenMode\" value=\"yes\" /><input type=\"hidden\" name=\"reqtype\" id=\"reqtype\" value=\"NOA\" /><input type=\"hidden\" name=\"amount\" id=\"amount\" value=\"1000\" /><input type=\"hidden\" name=\"currency\" id=\"currency\" value=\"CHF\" /><input type=\"hidden\" name=\"useAlias\" id=\"useAlias\" value=\"yes\" /><input type=\"hidden\" name=\"sign\" id=\"sign\" value=\"0402fb3fba8c6fcb40df9b7756e7e637\" /><input type=\"hidden\" name=\"refno\" id=\"refno\" value=\"ABCDEF\" /><input type=\"hidden\" name=\"uppCustomerDetails\" id=\"uppCustomerDetails\" /><input type=\"hidden\" name=\"uppCustomerEmail\" id=\"uppCustomerEmail\" value=\"customer@email.com\" />"
    end
  end

  context "successful response" do
    before do
      allow_any_instance_of(Datatrans::Web::Transaction::AuthorizeResponse).to receive(:params).and_return(@successful_response)
    end

    context "process" do
      it "handles a valid datatrans authorize response" do
        @transaction = Datatrans::Web::Transaction.new(@datatrans, @valid_params)
        expect(@transaction.authorize).to be true
      end
    end
  end

  context "successful response (swiss post)" do
    before do
      allow_any_instance_of(Datatrans::Web::Transaction::AuthorizeResponse).to receive(:params).and_return(@successful_swisspost_response)
    end

    context "process" do
      it "handles a valid datatrans authorize response" do
        @transaction = Datatrans::Web::Transaction.new(@datatrans, @valid_params)
        expect(@transaction.authorize).to be true
      end
    end
  end

  context "canceled response" do
    before do
      allow_any_instance_of(Datatrans::Web::Transaction::AuthorizeResponse).to receive(:params).and_return(@canceled_response)
      @transaction = Datatrans::Web::Transaction.new(@datatrans, @valid_params)
    end

    it "handles a canceled datatrans authorize response" do
      expect(@transaction.authorize).to be false
    end
  end

  context "compromised response" do
    before do
      fake_response = @successful_response
      fake_response[:sign2] = 'invalid'
      allow_any_instance_of(Datatrans::Web::Transaction::AuthorizeResponse).to receive(:params).and_return(fake_response)
      @transaction = Datatrans::Web::Transaction.new(@datatrans, @valid_params)
    end

    it "raises an exception if sign2 is invalid" do
      expect {
        @transaction.authorize
      }.to raise_error(Datatrans::InvalidSignatureError)
    end
  end

  context "failed response" do
    before do
      allow_any_instance_of(Datatrans::Web::Transaction::AuthorizeResponse).to receive(:params).and_return(@failed_response)
      @transaction = Datatrans::Web::Transaction.new(@datatrans, @valid_params)
    end

    context "process" do
      it "handles a failed datatrans authorize response" do
        expect(@transaction.authorize).to be false
      end

      it "returns error details" do
        @transaction.authorize
        expect(@transaction.error_code.length).to be > 0
        expect(@transaction.error_message.length).to be > 0
        expect(@transaction.error_detail.length).to be > 0
      end
    end
  end
end
