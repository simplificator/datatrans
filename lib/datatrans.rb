module Datatrans
  WEB_AUTHORIZE_URL = 'https://payment.datatrans.biz/upp/jsp/upStart.jsp'
  XML_AUTHORIZE_URL = 'https://payment.datatrans.biz/upp/jsp/XML_authorize.jsp'
  XML_SETTLEMENT_URL = 'https://payment.datatrans.biz/upp/jsp/XML_processor.jsp'

  TEST_WEB_AUTHORIZE_URL = 'https://pilot.datatrans.biz/upp/jsp/upStart.jsp'
  TEST_XML_AUTHORIZE_URL = 'https://pilot.datatrans.biz/upp/jsp/XML_authorize.jsp'
  TEST_XML_SETTLEMENT_URL = 'https://pilot.datatrans.biz/upp/jsp/XML_processor.jsp'

  mattr_accessor :merchant_id
  mattr_accessor :sign_key

  mattr_reader :web_authorize_url
  mattr_reader :xml_authorize_url
  mattr_reader :xml_settlement_url
  
  def self.configure
    self.environment = :development # default
    yield self
  end
  
  def self.environment=(environment)
    case environment
    when :development
      @@web_authorize_url  = TEST_WEB_AUTHORIZE_URL
      @@xml_authorize_url  = TEST_XML_AUTHORIZE_URL
      @@xml_settlement_url = TEST_XML_SETTLEMENT_URL
    when :production
      @@web_authorize_url  = WEB_AUTHORIZE_URL
      @@xml_authorize_url  = XML_AUTHORIZE_URL
      @@xml_settlement_url = XML_SETTLEMENT_URL
    else
      raise "Unknown environment '#{environment}'. Available: :development, :production."
    end
  end
end

require 'datatrans/version'
require 'datatrans/notification'
require 'datatrans/transaction'

ActionView::Base.send :include, Datatrans::Notification::ViewHelper if defined? ActionView
