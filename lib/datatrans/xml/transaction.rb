require 'active_support/core_ext/hash'

module Datatrans::XML
  class Transaction
    attr_accessor :request
    attr_reader :response, :params
    
    def initialize(params)
      @params = params.symbolize_keys
    end
    
    def authorize
      self.request = AuthorizeRequest.new(params)
      @response = AuthorizeResponse.new(request.process)
      @response.successful?
    end
    
    def void
      self.request = VoidRequest.new(params)
      @response = VoidResponse.new(request.process)
      @response.successful?
    end
    
    def capture
      self.request = CaptureRequest.new(params)
      @response = CaptureResponse.new(request.process)
      @response.successful?
    end
    
    # TODO: purchase, credit methods
    
    
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
