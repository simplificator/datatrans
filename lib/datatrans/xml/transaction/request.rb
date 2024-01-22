require "httparty"
require "builder"

class Datatrans::XML::Transaction
  class Request
    attr_accessor :params, :datatrans

    def post(url, options = {})
      options = options
        .merge(datatrans.proxy)
        .merge(basic_auth: {username: datatrans.merchant_id, password: datatrans.password})
      HTTParty.post(url, **options)
    end

    def initialize(datatrans, params)
      warn "DEPRECATION WARNING: Support for the XML API is deprecated and will be removed in the next major version. Please use the JSON API instead."

      @datatrans = datatrans
      @params = params
    end

    def process
      raise "overwrite in subclass!"
    end

    private

    include Datatrans::Common

    def build_xml_request(service)
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.tag! "#{service}Service", version: 1 do
        xml.body merchantId: datatrans.merchant_id do |body|
          xml.transaction refno: params[:refno] do
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
