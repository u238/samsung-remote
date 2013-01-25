require 'rubygems'
require "bundler/setup"


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
RestClient.log = Logger.new "foo.logcat "

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


class SamsungDeviceProxy
  def initialize(cookies, config)
    @options = {
      'master_duid' => "",
      'duid' => config['duid'],
      :Accept => 'application/xml, text/xml, */*; q=0.01',
      :Cookie => ""
    }

    @options[:Cookie] = cookies.collect { |cookie| 
      cookie.to_s 
    }.join("; ")

  end

  def getDeviceState()
    result = RestClient.get('http://global.samsungsmartappliance.com/Device/getDeviceState?_=1359113709621', @options)
    
    Nokogiri::XML(result)
  end 
end

class SamsungCommunicationProxy
  def initialize(cookies, config)
    @options = {}

  end

  #
  # Execute a 'selectDevice' call, returning the capabilities of the air conditioner.
  #
  # This appears to be the kind of file a UPnP discovery would look for too.
  #
  def selectDevice()
    result = RestClient.get('http://global.samsungsmartappliance.com/Communication/selectDevice?_=1359113706632', @options)
    
    Nokogiri::XML(result)
  end

  def getDeviceState()
    result = RestClient.get('http://global.samsungsmartappliance.com/Communication/getDeviceState?_=1359113709621', @options)
    
    Nokogiri::XML(result)
  end

  #
  # Sends a command to the device.
  #
  # Response will include a CommandId, which can be polled for success via checkControl()
  #
  def setControl(xml)
      result = RestClient.post('http://global.samsungsmartappliance.com/Communication/setControl', xml, @options.merge(:content_type => 'text/xml'))


    Nokogiri::XML(result)
  end

  #
  # Poll for the status of a previously sent command.
  #
  # <rsp stat="ok"><ControlResult DUID="...">Processing</ControlResult></rsp>
  # <rsp stat="ok"><ControlResult DUID="...">Success</ControlResult></rsp>
  #
  def checkControl(id)
   result = RestClient.get('http://global.samsungsmartappliance.com/Communication/checkControl?_=1359117596992', @options.merge('CommandId' => id))

    Nokogiri::XML(result) 
  end

end

# A particular air conditionerco
class Boracay
  def initialize(communication_proxy)
    @communication_proxy = communication_proxy
  end

  def on
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="1359114535"><Device><Status Power="On" /></Device></ControlCommand>')
  end

  def off
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="1359114535"><Device><Status Power="Off" /></Device></ControlCommand>')    
  end

  # <OperationMode type="string">
  #   <AvailableList>
  #     <Auto/>
  #     <Cool/>
  #     <Dry/>
  #     <Wind/>
  #     <Heat/>
  #   </AvailableList>
  # </OperationMode> 
  def operation_mode(type)
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="1359118485" ><Device><Status OperationMode="#{type}" /></Device></ControlCommand>')    
  end

  # <TempSet type="int">
  #   <AvailableList>
  #     <AvailableRange MinValue="16" MaxValue="23" Interval="1">
  #       <DependencySet>
  #         <Dependency RestrictionItem="OperationMode" ErrorCode="OP001">
  #           <PermittedValue Value="Auto"/>
  #           <PermittedValue Value="Heat"/>
  #           <PermittedValue Value="Cool"/>
  #         </Dependency>
  #         <Dependency RestrictionItem="ConvenientMode" ErrorCode="OP001">
  #           <PermittedValue Value="Off"/>
  #           <PermittedValue Value="Quiet"/>
  #           <PermittedValue Value="Sleep"/>
  #           <PermittedValue Value="DlightCool"/>
  #         </Dependency>
  #       </DependencySet>
  #     </AvailableRange>
  #     <AvailableRange MinValue="24" MaxValue="30" Interval="1">
  #       <DependencySet>
  #         <Dependency RestrictionItem="OperationMode" ErrorCode="OP001">
  #           <PermittedValue Value="Auto"/>
  #           <PermittedValue Value="Heat"/>
  #           <PermittedValue Value="Cool"/>
  #         </Dependency>
  #       </DependencySet>
  #     </AvailableRange>
  #   </AvailableList>
  # </TempSet>
  def set_temperature(temp)
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="1359118580" ><Device><Status TempSet="#{temp}" /></Device></ControlCommand>')      
  end

  # <Spi type="string">
  #   <AvailableList>
  #     <On/>
  #     <Off/>
  #   </AvailableList>
  # </Spi>
  def set_spi
    raise "Not yet implemented"
  end

# <ConvenientMode type="string">
#         <AvailableList>
#           <Off/>
#           <Smart>
#             <DependencySet>
#               <Dependency RestrictionItem="Power" ErrorCode="OP011">
#                 <PermittedValue Value="On"/>
#               </Dependency>
#               <Dependency RestrictionItem="OperationMode" ErrorCode="OP011">
#                 <PermittedValue Value="Cool"/>
#               </Dependency>
#             </DependencySet>
#           </Smart>
#           <Quiet/>
#           <Sleep/>
#           <DlightCool>
#             <DependencySet>
#               <Dependency RestrictionItem="Power" ErrorCode="OP011">
#                 <PermittedValue Value="On"/>
#               </Dependency>
#               <Dependency RestrictionItem="OperationMode" ErrorCode="OP011">
#                 <PermittedValue Value="Cool"/>
#               </Dependency>
#             </DependencySet>
#           </DlightCool>
#         </AvailableList>
#       </ConvenientMode>
  def set_convient_mode
    raise 'Not yet implemented'
  end
end



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

proxy = SamsungCommunicationProxy.new(a.cookies, config)
boracay = Boracay.new(proxy)
boracay.on()
sleep(10)
boracay.operation_mode('Cool')
sleep(10)
boracay.set_temperature(22)
sleep(20)
boracay.off()