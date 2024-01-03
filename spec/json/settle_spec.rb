require "spec_helper"

describe Datatrans::JSON::Transaction::Settle do
  before do
    @valid_params_authorize = {
      currency: "CHF",
      refno: "B4B4B4B4B",
      amount: 1337,
      payment_methods: ["ECA", "VIS"],
      success_url: "https://pay.sandbox.datatrans.com/upp/merchant/successPage.jsp",
      cancel_url: "https://pay.sandbox.datatrans.com/upp/merchant/cancelPage.jsp",
      error_url: "https://pay.sandbox.datatrans.com/upp/merchant/errorPage.jsp"
    }

    @valid_params_settle = {
      transaction_id: '230223022302230223',
      amount: 1337,
      currency: "CHF",
      refno: "B4B4B4B4B"
    }

    @successful_response_settle = {} # Empty hash as 204 No Content is expected for successful settlement

    @failed_response_settle = {
      "error" => {
        "code" => "INVALID_REQUEST",
        "message" => "Invalid transaction ID or parameters"
      }
    }
  end

  context "successful response" do
    before do
      allow_any_instance_of(Datatrans::JSON::Transaction::Settle).to receive(:process).and_return(@successful_response_settle)
    end

    it "handles a successful settle request" do
      transaction = Datatrans::JSON::Transaction.new(@datatrans, @valid_params_settle)
      expect(transaction.settle).to be true
    end
  end

  context "failed response" do
    before do
      allow_any_instance_of(Datatrans::JSON::Transaction::Settle).to receive(:process).and_return(@failed_response_settle)
    end

    it "handles a failed settle request" do
      transaction = Datatrans::JSON::Transaction.new(@datatrans, @valid_params_settle)
      expect(transaction.settle).to be false
      expect(transaction.response.error_code).to eq "INVALID_REQUEST"
      expect(transaction.response.error_message).to eq "Invalid transaction ID or parameters"
    end
  end
end
