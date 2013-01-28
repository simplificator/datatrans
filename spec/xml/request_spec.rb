require 'spec_helper'

describe Datatrans::XML::Transaction::Request do
  describe "ClassMethods" do
    describe "set_default_options" do
      it "should set the current proxy settings" do
        Datatrans.configure do |config|
          config.proxy = {
            :host => "test.com",
            :port => 123,
            :user => "hans",
            :password => "wurst",
          }
        end
        Datatrans::XML::Transaction::Request.should_receive(:http_proxy).with(Datatrans.proxy[:host], Datatrans.proxy[:port], Datatrans.proxy[:user], Datatrans.proxy[:password])
        Datatrans::XML::Transaction::Request.set_default_options

        Datatrans.configure do |config|
          config.proxy = nil
        end
        Datatrans::XML::Transaction::Request.should_receive(:http_proxy).with(nil, nil, nil, nil)
        Datatrans::XML::Transaction::Request.set_default_options
      end
    end

    describe "post" do
      it "should update the default options and perform the request afterwards" do
        Datatrans::XML::Transaction::Request.should_receive(:set_default_options)
        Datatrans::XML::Transaction::Request.perform_request(Net::HTTP::Post, "http://example.com", :a => "b")
      end
    end
  end
end