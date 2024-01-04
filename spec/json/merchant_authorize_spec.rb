require "spec_helper"

describe Datatrans::JSON::Transaction::MerchantAuthorize do
  before do
    @successful_response = {
      "transactionId" => "230223022302230223",
      "acquirerAuthorizationCode" => "123456",
      "card" => {
        "masked" => "411111xxxxxx1111"
      }
    }

    @failed_response = {
      "error" => {
        "code" => "INVALID_PROPERTY",
        "message" => "authorize.card.alias or number is mandatory"
      }
    }

    @valid_params = {
      currency: "CHF",
      refno: "B4B4B4B4B",
      amount: 1000,
      card: {
        alias: "AAABcH0Bq92s3kgAESIAAbGj5NIsAHWC",
        expiryMonth: "01",
        expiryYear: "23"
      },
      auto_settle: true
    }

    @expected_request_body = {
      "currency": "CHF",
      "refno": "B4B4B4B4B",
      "amount": 1000,
      "card": {
        "alias": "AAABcH0Bq92s3kgAESIAAbGj5NIsAHWC",
        "expiryMonth": "01",
        "expiryYear": "23"
      },
      "autoSettle": true
    }

    @invalid_params = {
      currency: "CHF",
      refno: "B4B4B4B4B",
      amount: 1000,
      card: {
        expiryMonth: "01",
        expiryYear: "23"
      }
    }
  end

  context "successful response" do
    before do
      allow_any_instance_of(Datatrans::JSON::Transaction::MerchantAuthorize).to receive(:process).and_return(@successful_response)
    end

    it "generates correct request_body" do
      request = Datatrans::JSON::Transaction::MerchantAuthorize.new(@datatrans, @valid_params)
      expect(request.request_body).to eq(@expected_request_body)
    end

    it "#process handles a valid datatrans merchant authorize response" do
      transaction = Datatrans::JSON::Transaction.new(@datatrans, @valid_params)
      expect(transaction.merchant_authorize).to be true
    end
  end

  context "with autoSettle specified" do
    it "handles autoSettle correctly in request_body" do
      params_with_auto_settle = @valid_params.merge(auto_settle: false)
      request = Datatrans::JSON::Transaction::MerchantAuthorize.new(@datatrans, params_with_auto_settle)

      expected_request_body_without_auto_settle = @expected_request_body.merge(autoSettle: false)
      expect(request.request_body).to eq(expected_request_body_without_auto_settle)
    end
  end

  context "failed response" do
    before do
      allow_any_instance_of(Datatrans::JSON::Transaction::MerchantAuthorize).to receive(:process).and_return(@failed_response)
      @transaction = Datatrans::JSON::Transaction.new(@datatrans, @invalid_params)
    end

    it "#process handles a failed datatrans merchant authorize response" do
      expect(@transaction.merchant_authorize).to be false
    end

    it "returns error details" do
      @transaction.merchant_authorize
      expect(@transaction.response.error_code).to eq "INVALID_PROPERTY"
      expect(@transaction.response.error_message).to eq "authorize.card.alias or number is mandatory"
    end
  end
end
