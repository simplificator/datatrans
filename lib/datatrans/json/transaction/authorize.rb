require_relative "init"

class Datatrans::JSON::Transaction
  class Authorize < Init
    def initialize(datatrans, params)
      warn "[DEPRECATION] `Datatrans::JSON::Transaction::Authorize` is deprecated.  Please use `Datatrans::JSON::Transaction::Init` instead."
      super(datatrans, params)
    end
  end
end
