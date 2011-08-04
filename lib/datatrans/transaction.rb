require 'httparty'

class Datatrans::Transaction
  include HTTParty
  
  attr_reader :params
  
  def initialize(params)
    @params = params.symbolize_keys
  end
  
  def authorize
    @response = self.class.post(Datatrans.xml_authorize_url, 
      :headers => { 'Content-Type' => 'text/xml' },
      :body => build_authorize_request.to_s).parsed_response
    self
  end

  def capture
    @response = self.class.post(Datatrans.xml_settlement_url, 
      :headers => { 'Content-Type' => 'text/xml' },
      :body => build_capture_request.to_s).parsed_response
    self
  end
  
  def void
    @response = self.class.post(Datatrans.xml_settlement_url, 
      :headers => { 'Content-Type' => 'text/xml' },
      :body => build_void_request.to_s).parsed_response
    self
  end
  
  def transaction_id
    @response['authorizationService']['body']['transaction']['response']['upptransactionid'] rescue nil
  end
  
  def masked_cc
    @response['authorizationService']['body']['transaction']['response']['maskedcc'] rescue nil
  end
  
  
  private
  
  include Datatrans::Common
  
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

  def build_authorize_request
    build_xml_request(:authorization) do |xml|
      xml.amount params[:amount]
      xml.currency params[:currency]
      xml.aliasCC params[:aliasCC]
      xml.expm params[:expm]
      xml.expy params[:expy]
      xml.sign sign(Datatrans.merchant_id, params[:amount], params[:currency], params[:refno])
    end
  end
    
  def build_capture_request
    build_xml_request(:payment) do |xml|
      xml.amount params[:amount]
      xml.currency params[:currency]
      xml.uppTransactionId params[:transaction_id]
    end
  end
  
  def build_void_request
    build_xml_request(:payment) do |xml|
      xml.amount params[:amount]
      xml.currency params[:currency]
      xml.uppTransactionId params[:transaction_id]
      xml.reqtype 'DOA'
    end
  end
end
