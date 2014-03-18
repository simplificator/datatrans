require 'spec_helper'

describe Datatrans::XML::Transaction::CreditRequest do
  before do
    @successful_response = {
      "paymentService" => {
        "body" => {
          "transaction" => {
            "request" => {
              "amount" => "1000",
              "currency" => "CHF",
              "uppTransactionId" => "110808142256858007",
              "transtype" => "06",
              "reqtype" => "COA"
            },
            "response" => {
              "responseCode" => "01",
              "responseMessage" => "credit succeeded"
            },
            "refno" => "ABCDEF",
            "trxStatus" => "response"
          },
          "merchantId" => "1100001872",
          "status" => "accepted"
        },
        "version" => "1"
      }
    }

    @failed_response = {
      "paymentService" => {
        "body" => {
          "transaction" => {
            "request" => {
              "amount" => "1000",
              "currency" => "CHF",
              "uppTransactionId" => "110808143302868124",
              "transtype" => "06"
            },
            "error" => {
              "errorCode" => "1010",
              "errorMessage" => "cannot be credited",
              "errorDetail" => "amount exceeded"
            },
            "refno" => "ABCDEF",
            "trxStatus" => "response"
          },
          "merchantId" => "1100001872",
          "status" => "accepted"
        },
        "version" => "1"
      }
    }

    @valid_params = {
      :refno => 'ABCDEF',
      :amount => 1000,
      :currency => 'CHF',
      :transaction_id => '110808142256858007'
    }
  end

  context "successful response" do
    before do
      Datatrans::XML::Transaction::CreditRequest.any_instance.stub(:process).and_return(@successful_response)
    end

    context "build_credit_request" do
      it "generates a valid datatrans credit xml" do
        @request = Datatrans::XML::Transaction::CreditRequest.new(@datatrans, @valid_params)
        @request.send(:build_credit_request).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><paymentService version=\"1\"><body merchantId=\"1100000000\"><transaction refno=\"ABCDEF\"><request><amount>1000</amount><currency>CHF</currency><uppTransactionId>110808142256858007</uppTransactionId><transtype>06</transtype></request></transaction></body></paymentService>"
      end
    end

    context "process" do
      it "handles a valid datatrans credit response" do
        @transaction = Datatrans::XML::Transaction.new(@datatrans, @valid_params)
        @transaction.credit.should be_true
      end
    end
  end

  context "failed response" do
    before do
      Datatrans::XML::Transaction::CreditRequest.any_instance.stub(:process).and_return(@failed_response)
      @transaction = Datatrans::XML::Transaction.new(@datatrans, @valid_params)
    end

    context "process" do
      it "handles a failed datatrans credit response" do
        @transaction.credit.should be_false
      end

      it "returns error details" do
        @transaction.credit
        @transaction.error_code.length.should > 0
        @transaction.error_message.length.should > 0
        @transaction.error_detail.length.should > 0
      end
    end
  end
end