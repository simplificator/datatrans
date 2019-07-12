require 'spec_helper'

describe Datatrans::Common do
  context "sign" do
    before do
      #class Request
      # include Datatrans::Common
      #end
      @request = Datatrans::XML::Transaction::Request.new(@datatrans, {})
    end

    it "generates the correct sign" do
      amount = 1000
      currency = 'CHF'
      reference_number = 'ABCEDF'

      expect(@request.sign(@datatrans.merchant_id, amount, currency, reference_number)).to eq '4e7d4d5bbde548c586f3b7f109635ffc'
    end
  end
end
