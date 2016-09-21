require 'datatrans/xml/transaction/request'
require 'datatrans/xml/transaction/response'

class Datatrans::XML::Transaction
  class AuthorizeRequest < Request
    def process
      post(self.datatrans.url(:xml_authorize_url),
        :headers => { 'Content-Type' => 'text/xml' },
        :body => build_authorize_request.to_s).parsed_response
    end

    private

    def build_authorize_request
      if params.has_key?(:reqtype)
        build_xml_request(:authorization) do |xml|
          xml.amount params[:amount]
          xml.currency params[:currency]
          xml.aliasCC params[:aliasCC]
          xml.expm params[:expm]
          xml.expy params[:expy]
          xml.reqtype params.has_key?(:reqtype) ? params[:reqtype] : 'NOA'
          xml.sign sign(self.datatrans.merchant_id, params[:amount], params[:currency], params[:refno])
        end
      else
        build_xml_request(:authorization) do |xml|
          xml.amount params[:amount]
          xml.currency params[:currency]
          xml.aliasCC params[:aliasCC]
          xml.expm params[:expm]
          xml.expy params[:expy]
          xml.reqtype params.has_key?(:reqtype) ? params[:reqtype] : 'NOA'
          xml.sign sign(self.datatrans.merchant_id, params[:amount], params[:currency], params[:refno])
        end
      end
    end
  end

  class AuthorizeResponse < Response
    def successful?
      response_code == '01' && response_message == 'Authorized'
    end

    def response_code
      params_root_node['response']['responseCode'] rescue nil
    end

    def response_message
      params_root_node['response']['responseMessage'] rescue nil
    end

    def transaction_id
      params_root_node['response']['uppTransactionId'] rescue nil
    end

    def reference_number
      params_root_node['refno'] rescue nil
    end

    def authorization_code
      params_root_node['response']['authorizationCode'] rescue nil
    end

    def masked_cc
      params_root_node['response']['maskedCC'] rescue nil
    end

    def creditcard_alias
      params_root_node['request']['aliasCC'] rescue nil
    end

    def error_code
      params_root_node['error']['errorCode'] rescue nil
    end

    def error_message
      params_root_node['error']['errorMessage'] rescue nil
    end

    def error_detail
      params_root_node['error']['errorDetail'] rescue nil
    end

    private

    def params_root_node
      params['authorizationService']['body']['transaction']
    end
  end
end