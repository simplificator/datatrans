class Datatrans::XML::Transaction
  class Response
    attr_reader :params
    
    def initialize(params)
      @params = params
    end
    
    def successful?
      raise 'overwrite in subclass!'
    end
  end
end