require "active_support/core_ext/hash"

module Datatrans::XML
  class Transaction
    attr_accessor :request
    attr_reader :response, :params, :datatrans

    def initialize(datatrans, params)
      warn "DEPRECATION WARNING: Support for the XML API is deprecated and will be removed in the next major version. Please use the JSON API instead."

      @datatrans = datatrans
      @params = params.symbolize_keys
    end

    def authorize
      self.request = AuthorizeRequest.new(datatrans, params)
      @response = AuthorizeResponse.new(datatrans, request.process)
      @response.successful?
    end

    def void
      self.request = VoidRequest.new(datatrans, params)
      @response = VoidResponse.new(datatrans, request.process)
      @response.successful?
    end

    def capture
      self.request = CaptureRequest.new(datatrans, params)
      @response = CaptureResponse.new(datatrans, request.process)
      @response.successful?
    end

    def status
      self.request = StatusRequest.new(datatrans, params)
      @response = StatusResponse.new(datatrans, request.process)
      @response.successful?
    end

    # TODO: purchase, credit methods

    def respond_to_missing?(method, *)
      response.respond_to?(method.to_sym) || request.respond_to?(method.to_sym) || super
    end

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

require "datatrans/xml/transaction/authorize"
require "datatrans/xml/transaction/void"
require "datatrans/xml/transaction/capture"
require "datatrans/xml/transaction/status"
