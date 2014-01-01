require 'rubygems'
require "bundler/setup"
require './lib/samsung'

config = YAML.load_file('settings.yml')
log = Logger.new STDOUT
a = Mechanize.new { |agent|
  agent.user_agent = config['user_agent']
}
a.log = log

auth = Samsung::Web::Authenticator.new(log)
cookies = auth.login(a, config['user'], config['pass'], 'n7yqc6udv2')


options = {}
options[:cookie] = cookies.collect { |cookie| 
  cookie.to_s 
}.join("; ")

RestClient.log = log

proxy = Samsung::Web::CommunicationProxy.new
boracay = Samsung::Web::Boracay.new(proxy, config, options[:cookie])
boracay.control()

boracay.on()
sleep(10)
boracay.operation_mode('Cool')
sleep(10)
boracay.set_temperature(22)
sleep(20)
boracay.off()