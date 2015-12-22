require 'openssl'

module Datatrans::Common
  def sign(*fields)
    return nil unless self.datatrans.sign_key
    sign_by_key(self.datatrans.sign_key, fields)
  end

  def sign_2(*fields)
    sign(fields)
  end

  def sign_1(*fields)
    return nil unless self.datatrans.sign_key_1
    sign_by_key(self.datatrans.sign_key_1, fields)
  end

  private

  def sign_by_key(key, fields)
    key = key.split(/([a-f0-9][a-f0-9])/).reject(&:empty?)
    key = key.pack("H*" * key.size)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::MD5.new, key, fields.join)
  end
end
