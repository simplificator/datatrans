class Datatrans::JSON::Transaction
  class Response
    attr_accessor :params, :datatrans

    def initialize(datatrans, params)
      @datatrans = datatrans
      @params = params
    end

    def successful?
      raise "overwrite in subclass!"
    end

    def error_code
      params["error"]["code"]
    rescue
      nil
    end

    def error_message
      params["error"]["message"]
    rescue
      nil
    end
  end
end
