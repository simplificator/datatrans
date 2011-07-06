class Datatrans::Transaction
  include HTTParty
  
  attr_reader :params
  
  def initialize(params)
    @params = params.symbolize_keys
  end
  
  def authorize
    # TODO
  end

  def capture
    @response = self.class.post(Datatrans.xml_url, :headers => { 'Content-Type' => 'text/xml' },
      :body => build_capture_request.to_s).parsed_response
  end
  
  def success?
    @response['paymentService']['body']['transaction']['response'].present? rescue false
  end

  def error?
    @response['paymentService']['body']['transaction']['error'].present? rescue false
  end
  
  private
  
  def build_xml_request(service)
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.tag! "#{service}Service", :version => 1 do
      xml.body :merchantId => Datatrans.merchant_id do |body|
        xml.transaction :refno => params[:refno] do
          xml.request do
            yield body
          end
        end
      end
    end
    xml.target!
  end
  
  def build_capture_request
    build_xml_request(:payment) do |xml|
      xml.amount params[:amount]
      xml.currency params[:currency]
      xml.uppTransactionId params[:transaction_id]
    end
  end
end
