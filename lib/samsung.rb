require 'nokogiri'
require 'rest_client'
require 'mechanize'
require 'yaml'

require 'nokogiri'
require 'yaml'
require 'logger'
require 'openssl'
require 'logger'
require 'socket'

module Samsung
  module Web
  end
  module Physical
  end

  class Factory
    def self.an_ssl_client(config)
      context = OpenSSL::SSL::SSLContext.new
      context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      context.cert = OpenSSL::X509::Certificate.new(File.read("cert.pem"))
      context.key = OpenSSL::PKey::RSA.new(File.read('cert.pem'), '')

      tcp_client = TCPSocket.new config['ip'], 2878
      ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, context 
    end
  end
end

require File.dirname(__FILE__) + '/physical/authenticator'
require File.dirname(__FILE__) + '/physical/boracay'

require File.dirname(__FILE__) + '/web/authenticator'
require File.dirname(__FILE__) + '/web/device_proxy'
require File.dirname(__FILE__) + '/web/communication_proxy'
require File.dirname(__FILE__) + '/web/boracay'

