require 'rubygems'
require "bundler/setup"


require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'yaml'
config = YAML.load_file('settings.yml')



a = Mechanize.new { |agent|
  #agent.user_agent_alias = 'Mac Safari'
  agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.52 Safari/537.17'
}

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

result = login_page.form.submit

puts result.inspect



#<input type="hidden" name="serviceID" value="n7yqc6udv2">
#startSignIn.do
#/account
# 1.30s2ms
# SSOSignIn
# global.samsungsmartappliance.com/UserMgr
# 4.53s0ms
# SignInResult
# global.samsungsmartappliance.com/UserMgr
# 367ms0ms
# global.samsungsmartappliance.com
# global.samsungsmartappliance.com

# HeadersPreviewResponseCookiesTiming
# Request URL:https://account.samsung.com/account/startSignIn.do
# Request Method:POST
# Status Code:200 OK
# Request Headersview source
# Accept:text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
# Accept-Charset:ISO-8859-1,utf-8;q=0.7,*;q=0.3
# Accept-Encoding:gzip,deflate,sdch
# Accept-Language:en-GB,en-US;q=0.8,en;q=0.6
# Cache-Control:max-age=0
# Connection:keep-alive
# Content-Length:97
# Content-Type:application/x-www-form-urlencoded
# Cookie:DocType=HTML5; country_codes=au; WMONID=DxtdbDcH4dR; JSESSIONID=D7rtRBlLwzThvtbyNXq3Tf9SjzjYRjWTmbLFWktGMGhQJzNrwMFh!-965434118!-789712369; uid=k6negvc0xf; dotcomSiteCode=au; s_cc=true; s_lv=1359032254952; s_lv_s=Less%20than%201%20day; s_prop25=logged%20out; s_pv=au%3Aconsumer%3Ahome%20appliances%3Aairconditioner; s_sq=%5B%5BB%5D%5D; s_vi=[CS]v1|28809289850111BC-6000160640014F4E[CE]; fsr.s={"rid"=> "d1159f3-80523910-e962-a7c8-227df","ru"=> "https://www.google.com.au/","r"=> "www.google.com.au","st"=> "","to":3,"v":1,"c"=> "http://www.samsung.com/au/consumer/home-appliances/airconditioner","pv":2,"lc":{"d0":{"v":2,"s":false}},"cd":0}; s_ppv=30; serviceID=n7yqc6udv2; goBackURL=http://global.samsungsmartappliance.com/Home/Index; stopWatchStart=1359033104941; userid=daniel.oconnor%40gmail.com
# Host:account.samsung.com
# Origin:https://account.samsung.com
# Referer:https://account.samsung.com/account/check.do
# User-Agent:Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.52 Safari/537.17
# Form Dataview sourceview URL encoded
# serviceID:n7yqc6udv2
# inputUserID:daniel.oconnor@gmail.com
# inputPassword:udlhpAQ01
# remIdCheck:on
# Response Headersview source
# Cache-Control:no-cache, no-store, must-revalidate
# Connection:Keep-Alive
# Content-Encoding:gzip
# Content-Language:en-GB
# Content-Type:text/html; charset=UTF-8
# Date:Thu, 24 Jan 2013 13:11:47 GMT
# Expires:Thu, 01 Jan 1970 00:00:00 GMT
# Keep-Alive:timeout=5, max=10000
# Pragma:no-cache
# Server:Apache
# Set-Cookie:iPlanetDirectoryPro=AQIC5wM2LY4SfcxWHKhMHS1kQ%2FSAcw06%2F7viJeNhIEodD78%3D%40AAJTSQACMDIAAlMxAAIwMw%3D%3D%23; domain=.samsung.com; path=/
# Set-Cookie:uid=k6negvc0xf; domain=.samsung.com; path=/
# Set-Cookie:iPlanetDirectoryPro=AQIC5wM2LY4SfcxWHKhMHS1kQ%2FSAcw06%2F7viJeNhIEodD78%3D%40AAJTSQACMDIAAlMxAAIwMw%3D%3D%23; path=/
# Set-Cookie:uid=k6negvc0xf; path=/
# Transfer-Encoding:chunked
# Vary:Accept-Encoding,User-Agent
# X-Powered-By:Servlet/2.5 JSP/2.1
