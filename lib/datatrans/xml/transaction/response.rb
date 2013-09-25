class Datatrans::XML::Transaction
  class Response
    attr_reader :params, :datatrans

    def initialize(datatrans, params)
      @datatrans = datatrans
      @params = params
    end

    def successful?
      raise 'overwrite in subclass!'
    end
  end
end