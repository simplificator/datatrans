require 'active_support/core_ext/hash'

module Datatrans::Web
  class Transaction
    include Datatrans::Common

    attr_accessor :request
    attr_reader :response, :params, :datatrans

    def initialize(datatrans, params)
      @datatrans = datatrans
      params = params.to_hash
      params.symbolize_keys!
      params.reverse_merge!(:reqtype => 'NOA', :useAlias => 'yes', :hiddenMode => 'yes')
      @params = params
    end

    def signature
      sign(self.datatrans.merchant_id, params[:amount], params[:currency], params[:refno])
    end

    def authorize
      @response = AuthorizeResponse.new(datatrans, params)
      @response.successful?
    end

    def method_missing(method, *args, &block)
      if response.respond_to? method.to_sym
        response.send(method)
      else
        super
      end
    end
  end
end

require 'datatrans/web/transaction/authorize'
