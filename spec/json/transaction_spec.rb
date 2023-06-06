require "spec_helper"

describe Datatrans::JSON::Transaction do
  it "returns correct trasaction_path" do
    params = {transaction_id: "230208152517866296"}
    transaction = Datatrans::JSON::Transaction.new(@datatrans, params)

    expect(transaction.transaction_path).to eq "https://pay.sandbox.datatrans.com/v1/start/230208152517866296"
  end
end
