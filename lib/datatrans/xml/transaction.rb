require 'active_support/core_ext/hash'

module Datatrans::XML
  class Transaction
    attr_accessor :request
    attr_reader :response, :params, :datatrans

    def initialize(datatrans, params)
      @datatrans = datatrans
      @params = params.symbolize_keys
    end

    def authorize
      self.request = AuthorizeRequest.new(self.datatrans, params)
      @response = AuthorizeResponse.new(self.datatrans, request.process)
      @response.successful?
    end

    def void
      self.request = VoidRequest.new(self.datatrans, params)
      @response = VoidResponse.new(self.datatrans, request.process)
      @response.successful?
    end

    def capture
      self.request = CaptureRequest.new(self.datatrans, params)
      @response = CaptureResponse.new(self.datatrans, request.process)
      @response.successful?
    end

    def status
      self.request = StatusRequest.new(self.datatrans, params)
      @response = StatusResponse.new(self.datatrans, request.process)
      @response.successful?
    end

    def credit
      self.request = CreditRequest.new(self.datatrans, params)
      @response = CreditResponse.new(self.datatrans, request.process)
      @response.successful?
    end

    # TODO: purchase

    def method_missing(method, *args, &block)
      if response.respond_to? method.to_sym
        response.send(method)
      elsif request.respond_to? method.to_sym
        request.send(method)
      else
        super
      end
    end
  end
end

require 'datatrans/xml/transaction/authorize'
require 'datatrans/xml/transaction/void'
require 'datatrans/xml/transaction/capture'
require 'datatrans/xml/transaction/status'
require 'datatrans/xml/transaction/credit'

