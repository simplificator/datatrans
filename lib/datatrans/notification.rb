module Datatrans::Notification
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
end
