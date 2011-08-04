module Datatrans::Notification
  class InvalidSignatureError < StandardError; end
  
  class Base
    attr_reader :params
  
    def initialize(params)
      raise 'Please define Datatrans.sign_key!' unless Datatrans.sign_key.present?

      params = params.to_hash
      params.symbolize_keys!
      params.reverse_merge!({ :reqtype => 'NOA', :useAlias => 'Yes', :hiddenMode => 'Yes' })
      @params = params
    end
  
    def reference_number
      params[:refno]
    end


    protected
  
    include Datatrans::Common
  end
  
  class Request < Base
    def signature
      sign(Datatrans.merchant_id, params[:amount], params[:currency], params[:refno])
    end
  end

  class Response < Base
    def valid_signature?
      sign(Datatrans.merchant_id, params[:amount], params[:currency], params[:uppTransactionId]) == params[:sign2]
    end

    def transaction_id
      params[:uppTransactionId]
    end

    def creditcard_alias
      params[:aliasCC]
    end
    
    def payment_method
      params[:pmethod]
    end
    
    def success?
      params[:status] == 'success'
    end

    def cancel?
      params[:status] == 'cancel'
    end

    def error?
      params[:status] == 'error'
    end
  end

  module ViewHelper
    def datatrans_notification_request_hidden_fields(request)
      [
        hidden_field_tag(:merchantId, Datatrans.merchant_id),
        hidden_field_tag(:hiddenMode, request.params[:hiddenMode]),
        hidden_field_tag(:reqtype, request.params[:reqtype]),
        hidden_field_tag(:amount, request.params[:amount]),
        hidden_field_tag(:currency, request.params[:currency]),
        hidden_field_tag(:useAlias, request.params[:useAlias]),
        hidden_field_tag(:sign, request.signature),
        hidden_field_tag(:refno, request.params[:refno]),
        hidden_field_tag(:uppCustomerName, request.params[:uppCustomerName]),
        hidden_field_tag(:uppCustomerEmail, request.params[:uppCustomerEmail])
      ].join.html_safe
    end
  end
end
