require "active_support/core_ext/hash"

module Datatrans::JSON
  class Transaction
    attr_accessor :request
    attr_reader :response, :params, :datatrans

    def initialize(datatrans, params)
      @datatrans = datatrans
      @params = params
    end

    def authorize
      self.request = Authorize.new(datatrans, params)
      @response = AuthorizeResponse.new(datatrans, request.process)
      @response.successful?
    end

    def merchant_authorize
      self.request = MerchantAuthorize.new(datatrans, params)
      @response = MerchantAuthorizeResponse.new(datatrans, request.process)
      @response.successful?
    end

    def status
      self.request = Status.new(datatrans, params)
      @response = StatusResponse.new(datatrans, request.process)
      @response.successful?
    end

    def settle
      self.request = Settle.new(datatrans, params)
      @response = SettleResponse.new(datatrans, request.process)
      @response.successful?
    end

    def transaction_path
      datatrans.url(:start_json_transaction, transaction_id: params[:transaction_id])
    end
  end
end

require "datatrans/json/transaction/authorize"
require "datatrans/json/transaction/merchant_authorize"
require "datatrans/json/transaction/status"
require "datatrans/json/transaction/settle"
