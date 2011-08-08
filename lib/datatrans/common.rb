require 'openssl'

module Datatrans::Common
  def sign(*fields)
    key = Datatrans.sign_key.split(/([a-f0-9][a-f0-9])/).reject(&:empty?)
    key = key.pack("H*" * key.size)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::MD5.new, key, fields.join)
  end
end