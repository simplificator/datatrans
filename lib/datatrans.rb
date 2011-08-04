module Datatrans
  BASE_URL = 'https://payment.datatrans.biz'
  WEB_AUTHORIZE_URL = "#{BASE_URL}/upp/jsp/upStart.jsp"
  XML_AUTHORIZE_URL = "#{BASE_URL}/upp/jsp/XML_authorize.jsp"
  XML_SETTLEMENT_URL = "#{BASE_URL}/upp/jsp/XML_processor.jsp"

  TEST_BASE_URL = 'https://pilot.datatrans.biz'
  TEST_WEB_AUTHORIZE_URL = "#{TEST_BASE_URL}/upp/jsp/upStart.jsp"
  TEST_XML_AUTHORIZE_URL = "#{TEST_BASE_URL}/upp/jsp/XML_authorize.jsp"
  TEST_XML_SETTLEMENT_URL = "#{TEST_BASE_URL}/upp/jsp/XML_processor.jsp"

  mattr_accessor :merchant_id
  mattr_accessor :sign_key

  mattr_reader :base_url
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
      @@base_url           = TEST_BASE_URL
      @@web_authorize_url  = TEST_WEB_AUTHORIZE_URL
      @@xml_authorize_url  = TEST_XML_AUTHORIZE_URL
      @@xml_settlement_url = TEST_XML_SETTLEMENT_URL
    when :production
      @@base_url           = BASE_URL
      @@web_authorize_url  = WEB_AUTHORIZE_URL
      @@xml_authorize_url  = XML_AUTHORIZE_URL
      @@xml_settlement_url = XML_SETTLEMENT_URL
    else
      raise "Unknown environment '#{environment}'. Available: :development, :production."
    end
  end
end

require 'datatrans/version'
require 'datatrans/common'
require 'datatrans/notification'
require 'datatrans/transaction'

ActionView::Base.send :include, Datatrans::Notification::ViewHelper if defined? ActionView
