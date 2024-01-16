require "spec_helper"

describe Datatrans::XML::Transaction::Request do
  describe "Proxy" do
    describe "configured" do
      before(:each) do
        @datatrans = Datatrans::Config.new(
          merchant_id: "1100000000",
          sign_key: "d777c17ba2010282c2d2350a68b441ca07a799d294bfaa630b7c8442207c0b69703cc55775b0ca5a4e455b818a9bb10a43669c0c20ce31f4a43f10e0cabb9525",
          password: "basic_auth_password",
          key: "value",
          proxy: {
            http_proxyaddr: "proxy.com",
            http_proxyport: 80,
            http_proxyuser: "hans",
            http_proxpass: "xxx"
          },
          environment: :development
        )
      end
      it "forward those options to HTTParty" do
        request = Datatrans::XML::Transaction::Request.new(@datatrans, {})
        expect(HTTParty).to receive(:post).with("lirum",
          basic_auth: {password: "basic_auth_password", username: "1100000000"},
          params: {foo: :bar},
          http_proxpass: "xxx",
          http_proxyuser: "hans",
          http_proxyaddr: "proxy.com",
          http_proxyport: 80)
        request.post("lirum", params: {foo: :bar})
      end
    end

    describe "not configured" do
      it "should not add any proxy settings" do
        request = Datatrans::XML::Transaction::Request.new(@datatrans, {})
        expect(HTTParty).to receive(:post).with("lirum", basic_auth: {password: "basic_auth_password", username: "1100000000"}, params: {foo: :bar})
        request.post("lirum", params: {foo: :bar})
      end
    end
  end
end
