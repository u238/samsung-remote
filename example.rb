require 'rubygems'
require "bundler/setup"
require './lib/samsung'

require 'nokogiri'
require 'rest_client'
require 'mechanize'
require 'yaml'

require 'logger'

config = YAML.load_file('settings.yml')

a = Mechanize.new { |agent|
  agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.52 Safari/537.17'
}
a.log =  Logger.new "mech.log"
RestClient.log = Logger.new "foo.log"

login_page = a.post('https://account.samsung.com/account/check.do', {
  :actionID => "StartAP",
  :serviceID => "n7yqc6udv2",
  :serviceName => "SmartAppliance",
  :domain => "eu.samsungsmartappliance.com",
  :countryCode => "GB",
  :languageCode => "en",
  :registURL => "http://global.samsungsmartappliance.com/UserMgr/SSOSignIn",
  :returnURL => "http://global.samsungsmartappliance.com/Home/Index",
  :goBackURL => "http://global.samsungsmartappliance.com/Home/Index",
  :idCheckURL => "",
  :signInURL => "",
  :signUpURL => "http://global.samsungsmartappliance.com/UserMgr/SSOModifyUser",
  :profileUpdateURL => "http://global.samsungsmartappliance.com/UserMgr/SSOModifyGo",
  :termsURL => "http://global.samsungsmartappliance.com/UserMgr/termsGBen",
  :privacyPolicyURL => "http://global.samsungsmartappliance.com/UserMgr/privacyPolicyGBen"
})

login_page.form['inputUserID'] = config['user']
login_page.form['inputPassword'] = config['pass']
login_page.form['serviceID'] = 'n7yqc6udv2'
login_page.form['remIdCheck'] = 'on'
login_page.form.action = 'https://account.samsung.com/account/startSignIn.do'

start_sso = login_page.form.submit
finish_sso = start_sso.form.submit

# We now should have cookies!

# result = a.get(
#   'http://global.samsungsmartappliance.com/Communication/selectDevice?_=1359113706632', 
#   [],
#   'http://global.samsungsmartappliance.com/',
#   {
#     'master_duid' => "",
#     'duid' => "7825AD103D06",
#     'accept' => 'application/xml, text/xml, */*; q=0.01'
#   }
# )
# pp a
# TODO Bother with DeviceView proxy?




options = {
  :cookie => ""
}

options[:cookie] = a.cookies.collect { |cookie| 
  cookie.to_s 
}.join("; ")

RestClient.add_before_execution_proc do |req, params|
  req.add_field 'master_duid', ""
  req.add_field 'duid', config['duid']
  req.add_field 'accept', 'application/xml, text/xml, */*; q=0.01'
  req.add_field 'cookie', options[:cookie]
end

proxy = Samsung::CommunicationProxy.new(a.cookies, config)
boracay = Samsung::Boracay.new(proxy)
boracay.on()
sleep(10)
boracay.operation_mode('Cool')
sleep(10)
boracay.set_temperature(22)
sleep(20)
boracay.off()