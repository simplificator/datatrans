require 'spec_helper'

describe Datatrans::XML::Transaction::CaptureRequest do
  before do
    @successful_response = {
      "paymentService" => {
        "body" => {
          "transaction" => {
            "request" => {
              "amount" => "1000",
              "currency" => "CHF",
              "uppTransactionId" => "110808142256858007",
              "reqtype" => "COA",
              "transtype" => "05"
            },
            "response" => {
              "responseCode" => "01",
              "responseMessage" => "settlement succeeded"
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
              "reqtype" => "DOA",
              "transtype" => "05"
            },
            "error" => {
              "errorCode" => "1010",
              "errorMessage" => "cannot be settled",
              "errorDetail" => "trx has another as authorized status: 92"
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
      Datatrans::XML::Transaction::CaptureRequest.any_instance.stub(:process).and_return(@successful_response)
    end

    context "build_capture_request" do
      it "generates a valid datatrans capture xml" do
        @request = Datatrans::XML::Transaction::CaptureRequest.new(@datatrans, @valid_params)
        @request.send(:build_capture_request).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><paymentService version=\"1\"><body merchantId=\"1100000000\"><transaction refno=\"ABCDEF\"><request><amount>1000</amount><currency>CHF</currency><uppTransactionId>110808142256858007</uppTransactionId></request></transaction></body></paymentService>"
      end
    end

    context "process" do
      it "handles a valid datatrans capture response" do
        @transaction = Datatrans::XML::Transaction.new(@datatrans, @valid_params)
        @transaction.capture.should be_true
      end
    end
  end

  context "failed response" do
    before do
      Datatrans::XML::Transaction::CaptureRequest.any_instance.stub(:process).and_return(@failed_response)
      @transaction = Datatrans::XML::Transaction.new(@datatrans, @valid_params)
    end

    context "process" do
      it "handles a failed datatrans capture response" do
        @transaction.capture.should be_false
      end

      it "returns error details" do
        @transaction.capture
        @transaction.error_code.length.should > 0
        @transaction.error_message.length.should > 0
        @transaction.error_detail.length.should > 0
      end
    end
  end
end