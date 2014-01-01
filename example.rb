require 'rubygems'
require "bundler/setup"
require './lib/samsung'

require 'nokogiri'
require 'rest_client'
require 'mechanize'
require 'yaml'

require 'logger'

config = YAML.load_file('settings.yml')
log = Logger.new "output.log"
a = Mechanize.new { |agent|
  agent.user_agent = config['user_agent']
}
a.log = log

auth = Samsung::Authenticator.new


cookies = auth.login(a, config['user'], config['pass'], 'n7yqc6udv2')


options = {}
options[:cookie] = cookies.collect { |cookie| 
  cookie.to_s 
}.join("; ")

RestClient.log = log
headers = {}
headers['master_duid'] = ""
headers['duid'] = config['duid']
headers['accept'] = 'application/xml, text/xml, */*; q=0.01'
headers['cookie'] = options[:cookie]

proxy = Samsung::WebCommunicationProxy.new
boracay = Samsung::Boracay.new(proxy, headers)
boracay.control()

boracay.on()
sleep(10)
boracay.operation_mode('Cool')
sleep(10)
boracay.set_temperature(22)
sleep(20)
boracay.off()