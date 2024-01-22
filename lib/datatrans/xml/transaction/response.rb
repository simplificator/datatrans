class Datatrans::XML::Transaction
  class Response
    attr_reader :params, :datatrans

    def initialize(datatrans, params)
      warn "DEPRECATION WARNING: Support for the XML API is deprecated and will be removed in the next major version. Please use the JSON API instead."

      @datatrans = datatrans
      @params = params
    end

    def successful?
      raise "overwrite in subclass!"
    end
  end
end
