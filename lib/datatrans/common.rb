require "openssl"

module Datatrans::Common
  def sign(*fields)
    return nil unless datatrans.sign_key
    key = datatrans.sign_key.split(/([a-f0-9][a-f0-9])/).reject(&:empty?)
    key = key.pack("H*" * key.size)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("MD5"), key, fields.join)
  end
end
