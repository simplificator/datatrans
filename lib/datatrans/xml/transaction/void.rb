require "datatrans/xml/transaction/request"
require "datatrans/xml/transaction/response"

class Datatrans::XML::Transaction
  class VoidRequest < Request
    def process
      post(datatrans.url(:xml_settlement_url),
        headers: {"Content-Type" => "text/xml"},
        body: build_void_request.to_s).parsed_response
    end

    private

    def build_void_request
      build_xml_request(:payment) do |xml|
        xml.amount params[:amount]
        xml.currency params[:currency]
        xml.uppTransactionId params[:transaction_id]
        xml.reqtype "DOA"
      end
    end
  end

  class VoidResponse < Response
    def successful?
      response_code == "01" && response_message == "cancellation succeeded"
    end

    def response_code
      params_root_node["response"]["responseCode"]
    rescue
      nil
    end

    def response_message
      params_root_node["response"]["responseMessage"]
    rescue
      nil
    end

    def transaction_id
      params_root_node["request"]["uppTransactionId"]
    rescue
      nil
    end

    def reference_number
      params_root_node["refno"]
    rescue
      nil
    end

    def error_code
      params_root_node["error"]["errorCode"]
    rescue
      nil
    end

    def error_message
      params_root_node["error"]["errorMessage"]
    rescue
      nil
    end

    def error_detail
      params_root_node["error"]["errorDetail"]
    rescue
      nil
    end

    private

    def params_root_node
      params["paymentService"]["body"]["transaction"]
    end
  end
end
