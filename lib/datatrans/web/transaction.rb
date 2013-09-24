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

  module ViewHelper
    def datatrans_notification_request_hidden_fields(datatrans, transaction)
      fields = [
        hidden_field_tag(:merchantId, datatrans.merchant_id),
        hidden_field_tag(:hiddenMode, transaction.params[:hiddenMode]),
        hidden_field_tag(:reqtype, transaction.params[:reqtype]),
        hidden_field_tag(:amount, transaction.params[:amount]),
        hidden_field_tag(:currency, transaction.params[:currency]),
        hidden_field_tag(:useAlias, transaction.params[:useAlias]),
        hidden_field_tag(:sign, transaction.signature),
        hidden_field_tag(:refno, transaction.params[:refno]),
        hidden_field_tag(:uppCustomerDetails, transaction.params[:uppCustomerDetails]),
      ]

      [:uppCustomerName, :uppCustomerEmail].each do |field_name|
        if transaction.params[field_name].present?
          fields << hidden_field_tag(field_name, transaction.params[field_name])
        end
      end

      fields.join.html_safe
    end
  end
end

require 'datatrans/web/transaction/authorize'
