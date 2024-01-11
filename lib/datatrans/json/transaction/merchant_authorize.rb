require 'httparty'
require 'datatrans/json/transaction/response'

class Datatrans::JSON::Transaction
  class MerchantAuthorize
    # class to authorize a transaction without user interaction https://api-reference.datatrans.ch/#tag/v1transactions/operation/authorize
    attr_accessor :params, :datatrans

    def initialize(datatrans, params)
      @datatrans = datatrans
      @params = params
    end

    def post(url, options = {})
      options = options
        .merge(self.datatrans.proxy)
        .merge(:basic_auth => { :username => self.datatrans.merchant_id, :password => self.datatrans.password })
      HTTParty.post(url, **options)
    end

    def process
      post(self.datatrans.url(:authorize_transaction),
        :headers => { 'Content-Type' => 'application/json' },
        :body => request_body.to_json).parsed_response
    end

    def request_body
      auto_settle = params[:auto_settle].nil? ? true : params[:auto_settle]

      {
        "currency": params[:currency],
        "refno": params[:refno],
        "amount": params[:amount],
        "card": params[:card],
        "autoSettle": auto_settle,
      }
    end
  end

  class MerchantAuthorizeResponse < Response
    def successful?
      params["error"].blank? && params["transactionId"].present?
    end
  end
end
