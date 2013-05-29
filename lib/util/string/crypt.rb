# encoding: utf-8
require 'openssl'
class Util::String::Crypt
  def self.encrypt(msg, pass = 'phrase', salt = nil)
    enc  = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    enc.encrypt
    enc.pkcs5_keyivgen(pass, salt)
    return enc.update(msg) + enc.final
  rescue
    return false
  end
  
  def self.decrypt(msg, pass = 'phrase', salt = nil)
    dec = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    dec.decrypt
    dec.pkcs5_keyivgen(pass, salt)
    dec.update(msg) + dec.final
  rescue
    return false
  end
end
