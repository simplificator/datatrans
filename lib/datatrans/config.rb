module Datatrans
  class Config
    ENVIRONMENTS = [:development, :production].freeze
    DEFAULT_ENVIRONMENT = :development

    DEFAULT_SIGN_KEY = false

    SUBDOMAINS = {
      payment_page: "pay",
      server_to_server_api: "api"
    }
    DOMAIN = "datatrans.com"

    attr_reader :environment, :merchant_id, :sign_key, :password, :proxy

    # Configure with following options
    # * :merchant_id (required)
    # * :password (required)
    # * :sign_key (defaults to false)
    # * :environment (defaults to :development, available environments are defined in ENVIRONMENTS)
    # * :proxy (a hash containing :http_proxyaddr, :http_proxyport, :http_proxyuser, :http_proxypass)
    def initialize(options = {})
      @merchant_id = options[:merchant_id]
      raise ArgumentError.new(":merchant_id is required") unless merchant_id
      self.environment = options[:environment] || DEFAULT_ENVIRONMENT
      @password = options[:password]
      raise ArgumentError.new(":password is required") unless password
      @sign_key = options[:sign_key] || DEFAULT_SIGN_KEY
      @proxy = options[:proxy] || {}
    end

    def environment=(environment)
      environment = environment.try(:to_sym)
      if ENVIRONMENTS.include?(environment)
        @environment = environment
      else
        raise "Unknown environment '#{environment}'. Available: #{ENVIRONMENTS.join(", ")}"
      end
    end

    # Access a url, is automatically scoped to environment
    def url(what, options = {})
      case what
      when :web_authorize_url
        warn "DEPRECATION WARNING: Support for the payment page is deprecated and will be removed in the next major version. Please use the JSON API instead."

        subdomain = SUBDOMAINS[:payment_page]
        path = "/upp/jsp/upStart.jsp"
      when :xml_authorize_url
        warn "DEPRECATION WARNING: Support for the XML API is deprecated and will be removed in the next major version. Please use the JSON API instead."

        subdomain = SUBDOMAINS[:server_to_server_api]
        path = "/upp/jsp/XML_authorize.jsp"
      when :xml_settlement_url
        warn "DEPRECATION WARNING: Support for the XML API is deprecated and will be removed in the next major version. Please use the JSON API instead."

        subdomain = SUBDOMAINS[:server_to_server_api]
        path = "/upp/jsp/XML_processor.jsp"
      when :xml_status_url
        warn "DEPRECATION WARNING: Support for the XML API is deprecated and will be removed in the next major version. Please use the JSON API instead."

        subdomain = SUBDOMAINS[:server_to_server_api]
        path = "/upp/jsp/XML_status.jsp"
      when :init_transaction
        subdomain = SUBDOMAINS[:server_to_server_api]
        path = "/v1/transactions"
      when :authorize_transaction
        subdomain = SUBDOMAINS[:server_to_server_api]
        path = "/v1/transactions/authorize"
      when :start_json_transaction
        subdomain = SUBDOMAINS[:payment_page]
        path = "/v1/start/#{options[:transaction_id]}"
      when :json_status_url
        # https://api.sandbox.datatrans.com/v1/transactions/{transactionId}
        subdomain = SUBDOMAINS[:server_to_server_api]
        path = "/v1/transactions/#{options[:transaction_id]}"
      when :json_settle_url
        # https://api.sandbox.datatrans.com/v1/transactions/{transactionId}/settle
        subdomain = SUBDOMAINS[:server_to_server_api]
        path = "/v1/transactions/#{options[:transaction_id]}/settle"
      else
        raise "Unknown wanted action '#{what}'."
      end
      subdomain += ".sandbox" unless environment == :production
      "https://#{subdomain}.#{DOMAIN}#{path}"
    end

    def web_transaction(*args)
      Web::Transaction.new(self, *args)
    end

    def xml_transaction(*args)
      XML::Transaction.new(self, *args)
    end

    def json_transaction(*args)
      JSON::Transaction.new(self, *args)
    end
  end
end
