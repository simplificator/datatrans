require 'spec_helper'

describe Datatrans::Config do
  describe "Instance Methods" do
    before do
      @datatrans = Datatrans::Config.new(:merchant_id => "xxx", :password => "yyy")
    end

    describe "web_transaction" do
      it "builds a new web transaction object" do
        expect(@datatrans.web_transaction({}).class).to eq(Datatrans::Web::Transaction)
      end
    end

    describe "xml_transaction" do
      it "builds a new xml transaction object" do
        expect(@datatrans.xml_transaction({}).class).to eq(Datatrans::XML::Transaction)
      end
    end
  end
end
