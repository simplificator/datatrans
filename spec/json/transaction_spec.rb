require "spec_helper"

describe Datatrans::JSON::Transaction do
  it "returns correct transaction_path" do
    params = {transaction_id: "230223022302230223"}
    transaction = Datatrans::JSON::Transaction.new(@datatrans, params)

    expect(transaction.transaction_path).to eq "https://pay.sandbox.datatrans.com/v1/start/230223022302230223"
  end
end
