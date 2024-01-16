require "spec_helper"

describe Datatrans::XML::Transaction::AuthorizeRequest do
  before do
    @successful_response = {
      "authorizationService" => {
        "body" => {
          "transaction" => {
            "request" => {
              "amount" => "1000",
              "currency" => "CHF",
              "aliasCC" => "70323122544311173",
              "expm" => "12",
              "expy" => "15",
              "sign" => "1d236349b97fac15b267becb0792d185",
              "reqtype" => "NOA"
            },
            "response" => {
              "responseCode" => "01",
              "responseMessage" => "Authorized",
              "uppTransactionId" => "110808142256858007",
              "authorizationCode" => "257128012",
              "acqAuthorizationCode" => "142257",
              "maskedCC" => "520000xxxxxx0007",
              "returnCustomerCountry" => "CHE"
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
      "authorizationService" => {
        "body" => {
          "transaction" => {
            "request" => {
              "amount" => "1000",
              "currency" => "CHF",
              "aliasCC" => "70323122544311173",
              "expm" => "12",
              "expy" => "15",
              "sign" => "1d236349b97fac15b267becb0792d185",
              "reqtype" => "NOA"
            },
            "error" => {
              "errorCode" => "2021",
              "errorMessage" => "missing value",
              "errorDetail" => "CC-alias"
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
      refno: "ABCDEF",
      amount: 1000,
      currency: "CHF",
      aliasCC: "3784982984234",
      expm: 12,
      expy: 15
    }
  end

  context "successful response" do
    before do
      allow_any_instance_of(Datatrans::XML::Transaction::AuthorizeRequest).to receive(:process).and_return(@successful_response)
    end

    context "build_authorize_request" do
      it "generates a valid datatrans authorize xml" do
        @request = Datatrans::XML::Transaction::AuthorizeRequest.new(@datatrans, @valid_params)
        expect(@request.send(:build_authorize_request)).to eq "<?xml version=\"1.0\" encoding=\"UTF-8\"?><authorizationService version=\"1\"><body merchantId=\"1100000000\"><transaction refno=\"ABCDEF\"><request><amount>1000</amount><currency>CHF</currency><aliasCC>3784982984234</aliasCC><expm>12</expm><expy>15</expy><sign>0402fb3fba8c6fcb40df9b7756e7e637</sign></request></transaction></body></authorizationService>"
      end
    end

    context "process" do
      it "handles a valid datatrans authorize response" do
        @transaction = Datatrans::XML::Transaction.new(@datatrans, @valid_params)
        expect(@transaction.authorize).to be true
      end
    end
  end

  context "failed response" do
    before do
      allow_any_instance_of(Datatrans::XML::Transaction::AuthorizeRequest).to receive(:process).and_return(@failed_response)
      @transaction = Datatrans::XML::Transaction.new(@datatrans, @valid_params)
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
