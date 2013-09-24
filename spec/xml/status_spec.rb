require 'spec_helper'

describe Datatrans::XML::Transaction::StatusRequest do
  before do
    @successful_response = {
      "statusService" => {
        "body" => {
          "transaction" => {
            "request" => {
              "uppTransactionId" => "111013090000394044",
              "reqtype" => "STA"
            },
            "response" => {
              "responseCode" => "2",
              "responseMessage" => "Trx debit waiting for daily settlement process",
              "refno" => "1234567-037",
              "amount" => "500",
              "currency" => "CHF",
              "authorizationCode" => "891104057",
              "pmethod" => "ECA",
            },
            "trxStatus" => "response"
          },
          "merchantId" => "1100002276",
          "status" => "accepted"
        },
        "version" => "1"
      }
    }

    @failed_response = {
      "statusService" => {
        "body" => {
          "transaction" => {
            "request" => {
              "uppTransactionId" => "111013090200394044",
              "reqtype" => "STA"
            },
            "response" => {
              "responseCode" => "20",
              "responseMessage" => "UPP record not found",
              "refno" => "",
              "amount" => "",
              "currency" => "",
              "authorizationCode" => "",
              "pmethod" => "",
            },
            "trxStatus" => "response"
          },
          "merchantId" => "1100002276",
          "status" => "accepted"
        },
        "version" => "1"
      }
    }

    @valid_params = {
      :transaction_id => '111013090000394044',
    }
  end

  context "successful response" do
    before do
      Datatrans::XML::Transaction::StatusRequest.any_instance.stub(:process).and_return(@successful_response)
    end

    context "build_status_request" do
      it "generates a valid datatrans status xml" do
        @request = Datatrans::XML::Transaction::StatusRequest.new(@datatrans, @valid_params)
        @request.send(:build_status_request).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><statusService version=\"1\"><body merchantId=\"1100000000\"><transaction refno=\"\"><request><uppTransactionId>111013090000394044</uppTransactionId></request></transaction></body></statusService>"
      end
    end

    context "process" do
      it "handles a valid datatrans status response" do
        @transaction = Datatrans::XML::Transaction.new(@datatrans, @valid_params)
        @transaction.status.should be_true
      end
    end
  end

  context "failed response" do
    before do
      Datatrans::XML::Transaction::StatusRequest.any_instance.stub(:process).and_return(@failed_response)
      @transaction = Datatrans::XML::Transaction.new(@datatrans, @valid_params)
    end

    context "process" do
      it "handles a failed datatrans status response" do
        @transaction.status.should be_false
      end
    end
  end
end