require "httparty"
require "datatrans/json/transaction/response"

class Datatrans::JSON::Transaction
  class Init
    # class to initialize a new transaction https://api-reference.datatrans.ch/#tag/v1transactions/operation/init
    attr_accessor :params, :datatrans

    def initialize(datatrans, params)
      @datatrans = datatrans
      @params = params
    end

    def post(url, options = {})
      options = options
        .merge(datatrans.proxy)
        .merge(basic_auth: {username: datatrans.merchant_id, password: datatrans.password})
      HTTParty.post(url, **options)
    end

    def process
      post(datatrans.url(:init_transaction),
        headers: {"Content-Type" => "application/json"},
        body: request_body.to_json).parsed_response
    end

    def request_body
      auto_settle = params[:auto_settle].nil? ? true : params[:auto_settle]

      body = {
        currency: params[:currency],
        refno: params[:refno],
        amount: params[:amount],
        autoSettle: auto_settle,
        paymentMethods: params[:payment_methods],
        redirect: {
          successUrl: params[:success_url],
          cancelUrl: params[:cancel_url],
          errorUrl: params[:error_url]
        }
      }

      body["option"] = params[:option] if params[:option].present?
      body.deep_merge!(params[:additional_options]) if params[:additional_options].present?

      body
    end
  end

  class InitResponse < Response
    def successful?
      params["error"].blank? && params["transactionId"].present?
    end
  end

  class AuthorizeResponse < InitResponse
    def initialize(datatrans, params)
      warn "[DEPRECATION] `Datatrans::JSON::Transaction::AuthorizeResponse` is deprecated.  Please use `Datatrans::JSON::Transaction::InitResponse` instead."
      super(datatrans, params)
    end
  end
end
