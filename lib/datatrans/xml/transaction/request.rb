require 'httparty'
require 'builder'

class Datatrans::XML::Transaction
  class Request
    include HTTParty

    attr_accessor :params

    def self.set_default_options
      if Datatrans.proxy
        proxy = Datatrans.proxy.symbolize_keys
        http_proxy(proxy[:host], proxy[:port], proxy[:user], proxy[:password])
      else
        http_proxy(nil, nil, nil, nil)
      end
    end

    def self.perform_request(*args, &block)
      set_default_options
      super
    end

    def initialize(params)
      @params = params
    end

    def process
      raise 'overwrite in subclass!'
    end

    private

    include Datatrans::Common

    def build_xml_request(service)
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.tag! "#{service}Service", :version => 1 do
        xml.body :merchantId => Datatrans.merchant_id do |body|
          xml.transaction :refno => params[:refno] do
            xml.request do
              yield body
            end
          end
        end
      end
      xml.target!
    end
  end
end