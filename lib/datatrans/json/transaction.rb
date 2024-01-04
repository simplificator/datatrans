require 'active_support/core_ext/hash'

module Datatrans::JSON
  class Transaction
    attr_accessor :request
    attr_reader :response, :params, :datatrans

    def initialize(datatrans, params)
      @datatrans = datatrans
      @params = params
    end

    def authorize
      self.request = Authorize.new(self.datatrans, params)
      @response = AuthorizeResponse.new(self.datatrans, request.process)
      @response.successful?
    end

    def merchant_authorize
      self.request = MerchantAuthorize.new(self.datatrans, params)
      @response = MerchantAuthorizeResponse.new(self.datatrans, request.process)
      @response.successful?
    end

    def status
      self.request = Status.new(self.datatrans, params)
      @response = StatusResponse.new(self.datatrans, request.process)
      @response.successful?
    end

    def transaction_path
      self.datatrans.url(:start_json_transaction, transaction_id: params[:transaction_id])
    end
  end
end

require 'datatrans/json/transaction/authorize'
require 'datatrans/json/transaction/merchant_authorize'
require 'datatrans/json/transaction/status'
