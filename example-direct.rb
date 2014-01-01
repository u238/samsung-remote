require 'rubygems'
require "bundler/setup"
require './lib/samsung'


config = YAML.load_file('settings.yml')
log = Logger.new STDOUT

unless config['token']
  auth = Samsung::Physical::Authenticator.new(Samsung::Factory.an_ssl_client(config), log)
  config['token'] = auth.login
end

boracay = Samsung::Physical::Boracay.new(Samsung::Factory.an_ssl_client(config), config, log)
boracay.login!

puts boracay.on().inspect
sleep(10)
puts boracay.operation_mode('Cool').inspect
sleep(10)
puts boracay.set_temperature(22).inspect
# puts boracay.get_temperature.inspect
sleep(20)
puts boracay.off().inspect
