require 'datatrans/xml/transaction/request'
require 'datatrans/xml/transaction/response'

class Datatrans::XML::Transaction
  class CreditRequest < Request
    def process
      post(
        self.datatrans.url(:xml_credit_url),
        :headers => {
          'Content-Type' => 'text/xml'
        },
        :body => build_credit_request.to_s
      ).parsed_response
    end

    private

    def build_credit_request
      build_xml_request(:payment) do |xml|
        xml.amount params[:amount]
        xml.currency params[:currency]
        xml.uppTransactionId params[:transaction_id]
        xml.transtype "06"
      end
    end
  end

  class CreditResponse < Response
    def successful?
      response_code == '01' && response_message == 'credit succeeded'
    end

    def response_code
      params_root_node['response']['responseCode'] rescue nil
    end

    def response_message
      params_root_node['response']['responseMessage'] rescue nil
    end

    def transaction_id
      params_root_node['request']['uppTransactionId'] rescue nil
    end

    def reference_number
      params_root_node['refno'] rescue nil
    end

    def error_code
      params_root_node['error']['errorCode'] rescue nil
    end

    def error_message
      params_root_node['error']['errorMessage'] rescue nil
    end

    def error_detail
      params_root_node['error']['errorDetail'] rescue nil
    end

    private

    def params_root_node
      params['paymentService']['body']['transaction']
    end
  end
end