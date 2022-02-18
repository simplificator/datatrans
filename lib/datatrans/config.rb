module Datatrans
  class Config
    ENVIRONMENTS = [:development, :production].freeze
    DEFAULT_ENVIRONMENT = :development

    DEFAULT_SIGN_KEY = false

    SUBDOMAINS = {
      payment_page: 'pay',
      server_to_server_api: 'api'
    }
    DOMAIN = 'datatrans.com'

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
      case what
      when :web_authorize_url
        subdomain = SUBDOMAINS[:payment_page]
        path = '/upp/jsp/upStart.jsp'
      when :xml_authorize_url
        subdomain = SUBDOMAINS[:server_to_server_api]
        path = '/upp/jsp/XML_authorize.jsp'
      when :xml_settlement_url
        subdomain = SUBDOMAINS[:server_to_server_api]
        path = '/upp/jsp/XML_processor.jsp'
      when :xml_status_url
        subdomain = SUBDOMAINS[:server_to_server_api]
        path = '/upp/jsp/XML_status.jsp'
      else
        raise "Unknown wanted action '#{what}'."
      end
      subdomain += '.sandbox' unless self.environment == :production
      "https://#{subdomain}.#{DOMAIN}#{path}"
    end

    def web_transaction(*args)
      Web::Transaction.new(self, *args)
    end

    def xml_transaction(*args)
      XML::Transaction.new(self, *args)
    end
  end
end
