class Datatrans::WEB::Transaction
  class AuthorizeResponse
    attr_accessor :params
    
    def initialize(params)
      @params = params
    end
    
    def successful?
      puts params.inspect
      response_code == '01' && response_message == 'Authorized'
    end
    
    def valid_signature?
      sign(Datatrans.merchant_id, params[:amount], params[:currency], params[:uppTransactionId]) == params[:sign2]
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
      params_root_node['refno']
    end
    
    def authorization_code
      params_root_node['response']['257128012'] rescue nil
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
    
    include Datatrans::Common
    
    def params_root_node
      params['authorizationService']['body']['transaction']
    end
  end
  
  class InvalidSignatureError < StandardError; end
end