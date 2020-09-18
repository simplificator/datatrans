module Datatrans
  class Config
    ENVIRONMENTS = [:development, :production].freeze
    DEFAULT_ENVIRONMENT = :development

    DEFAULT_SIGN_KEY = false

    BASE_URL_PRODUCTION = 'https://payment.datatrans.biz'.freeze
    BASE_URL_DEVELOPMENT = 'https://pilot.datatrans.biz'.freeze

    URLS = {
      :development => {
        :web_authorize_url  => "#{BASE_URL_DEVELOPMENT}/upp/jsp/upStart.jsp".freeze,
        :xml_authorize_url  => "#{BASE_URL_DEVELOPMENT}/upp/jsp/XML_authorize.jsp".freeze,
        :xml_settlement_url => "#{BASE_URL_DEVELOPMENT}/upp/jsp/XML_processor.jsp".freeze,
        :xml_status_url     => "#{BASE_URL_DEVELOPMENT}/upp/jsp/XML_status.jsp".freeze,
        :xml_credit_url     => "#{BASE_URL_DEVELOPMENT}/upp/jsp/XML_processor.jsp".freeze,
      },
      :production => {
        :web_authorize_url  => "#{BASE_URL_PRODUCTION}/upp/jsp/upStart.jsp".freeze,
        :xml_authorize_url  => "#{BASE_URL_PRODUCTION}/upp/jsp/XML_authorize.jsp".freeze,
        :xml_settlement_url => "#{BASE_URL_PRODUCTION}/upp/jsp/XML_processor.jsp".freeze,
        :xml_status_url     => "#{BASE_URL_PRODUCTION}/upp/jsp/XML_status.jsp".freeze,
        :xml_credit_url     => "#{BASE_URL_PRODUCTION}/upp/jsp/XML_processor.jsp".freeze,
      }.freeze
    }.freeze

    attr_reader :environment, :merchant_id, :sign_key, :proxy

    # Configure with following options
    # * :merchant_id (required)
    # * :sign_key (defaults to false)
    # * :environment (defaults to :development, available environments are defined in ENVIRONMENTS)
    # * :proxy (a hash containing :http_proxyaddr, :http_proxyport, :http_proxyuser, :http_proxypass)
    def initialize(options = {})
      @merchant_id = options[:merchant_id]
      raise ArgumentError.new(":merchant_id is required") unless self.merchant_id
      self.environment = options[:environment] || DEFAULT_ENVIRONMENT
      @sign_key = options[:sign_key] || DEFAULT_SIGN_KEY
      @proxy = options[:proxy] || {}
    end

    def environment=(environment)
      environment = environment.try(:to_sym)
      if ENVIRONMENTS.include?(environment)
        @environment = environment
      else
        raise "Unknown environment '#{environment}'. Available: #{ENVIRONMENTS.join(', ')}"
      end
    end

    # Access a url, is automatically scoped to environment
    def url(what)
      URLS[self.environment][what]
    end

    def web_transaction(*args)
      Web::Transaction.new(self, *args)
    end

    def xml_transaction(*args)
      XML::Transaction.new(self, *args)
    end
  end
end
