require 'datatrans/xml/transaction/request'
require 'datatrans/xml/transaction/response'

class Datatrans::XML::Transaction
  class StatusRequest < Request
    def process
      self.class.post(
        Datatrans.xml_status_url,
        :headers => {
          'Content-Type' => 'text/xml'
        },
        :body => build_status_request.to_s
      ).parsed_response
    end


    private

    def build_status_request
      build_xml_request(:status) do |xml|
        xml.uppTransactionId params[:transaction_id]
      end
    end
  end

  class StatusResponse < Response
    def successful?
      [
        '1', # Transaction ready for settlement (trx authorized)
        '2', # Transaction debit waiting for daily settlement process
        '3', # Transaction credit waiting for daily settlement process
      ].include?(response_code)
    end

    def response_code
      params_root_node['response']['responseCode'] rescue nil
    end

    def response_message
      params_root_node['response']['responseMessage'] rescue nil
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

    def reference_number
      params_root_node['response']['refno'] rescue nil
    end

    def amount
      params_root_node['response']['amount'] rescue nil
    end

    def currency
      params_root_node['response']['currency'] rescue nil
    end

    def authorization_code
      params_root_node['response']['authorizationCode'] rescue nil
    end

    def authorization_code
      params_root_node['response']['authorizationCode'] rescue nil
    end

    def payment_method
      params_root_node['response']['pmethod'] rescue nil
    end

    private

    def params_root_node
      params['statusService']['body']['transaction']
    end
  end
end