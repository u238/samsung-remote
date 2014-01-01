require 'rubygems'
require "bundler/setup"
require './lib/samsung'


config = YAML.load_file('settings.yml')
log = Logger.new STDOUT

require 'socket'

def an_ssl_client(config)
  context = OpenSSL::SSL::SSLContext.new
  tcp_client = TCPSocket.new config['ip'], 2878
  ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, context 
end

unless config['token']
  auth = Samsung::Physical::Authenticator.new(an_ssl_client(config), log)
  config['token'] = auth.login
end

boracay = Samsung::Physical::Boracay.new(an_ssl_client(config), config, log)
boracay.login!

puts boracay.on().inspect
sleep(10)
puts boracay.operation_mode('Cool').inspect
sleep(10)
puts boracay.set_temperature(22).inspect
puts boracay.get_temperature.inspect
sleep(20)
puts boracay.off().inspect
