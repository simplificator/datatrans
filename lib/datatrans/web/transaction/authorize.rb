class Datatrans::Web::Transaction
  class AuthorizeResponse
    attr_accessor :params
    
    def initialize(params)
      @params = params
    end
    
    def successful?
      raise Datatrans::InvalidSignatureError unless valid_signature?
      response_code == '01' && response_message == 'Authorized' && !errors_occurred?
    end
    
    def valid_signature?
      return true if errors_occurred? # no sign2 sent on error
      sign(Datatrans.merchant_id, params[:amount], params[:currency], params[:uppTransactionId]) == params[:sign2]
    end
    
    def response_code
      params[:responseCode] rescue nil
    end
    
    def response_message
      params[:responseMessage] rescue nil
    end
    
    def transaction_id
      params[:uppTransactionId] rescue nil 
    end
    
    def reference_number
      params[:refno] rescue nil 
    end
    
    def authorization_code
      params[:authorizationCode] rescue nil
    end

    def masked_cc
      params[:maskedCC] rescue nil
    end
    
    def creditcard_alias
      params[:aliasCC] rescue nil
    end
    
    def error_code
      params[:errorCode] rescue nil
    end
    
    def error_message
      params[:errorMessage] rescue nil
    end
    
    def error_detail
      params[:errorDetail] rescue nil
    end
    
    
    private
    
    def errors_occurred?
      error_code || error_message || error_detail
    end
    
    include Datatrans::Common
  end
end