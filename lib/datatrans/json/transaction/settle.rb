require "httparty"
require "datatrans/json/transaction/response"

class Datatrans::JSON::Transaction
  class Settle
    # Class to settle a transaction https://api-reference.datatrans.ch/#tag/v1transactions/operation/settle
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
      post(datatrans.url(:json_settle_url, transaction_id: params[:transaction_id]),
        headers: {"Content-Type" => "application/json"},
        body: request_body.to_json).parsed_response
    end

    def request_body
      {
        currency: params[:currency],
        amount: params[:amount],
        refno: params[:refno]
      }
    end
  end

  class SettleResponse < Response
    def successful?
      params["error"].blank?
    end
  end
end
