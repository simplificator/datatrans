module Datatrans::Web
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
        hidden_field_tag(:uppCustomerDetails, transaction.params[:uppCustomerDetails])
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
