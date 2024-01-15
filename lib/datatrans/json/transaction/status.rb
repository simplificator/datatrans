require "httparty"
require "datatrans/json/transaction/response"

class Datatrans::JSON::Transaction
  class Status
    # class to check a transaction status and get a transaction info: https://api-reference.datatrans.ch/#tag/v1transactions/operation/status
    attr_accessor :params, :datatrans

    def initialize(datatrans, params)
      @datatrans = datatrans
      @params = params
    end

    def get(url, options = {})
      options = options
        .merge(datatrans.proxy)
        .merge(basic_auth: {username: datatrans.merchant_id, password: datatrans.password})
      HTTParty.get(url, **options)
    end

    def process
      get(datatrans.url(:json_status_url, transaction_id: params[:transaction_id]),
        headers: {"Content-Type" => "application/json"}).parsed_response
    end
  end

  class StatusResponse < Response
    def successful?
      params["error"].blank? && ["settled", "transmitted"].include?(response_code)
    end

    def response_code
      params["status"]
    rescue
      nil
    end

    def reference_number
      params["refno"]
    rescue
      nil
    end

    def amount
      params["detail"]["settle"]["amount"]
    rescue
      nil
    end
  end
end
