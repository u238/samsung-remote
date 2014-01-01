module Samsung
  module Web
  end
  module Physical
  end
end

class Samsung::Web::DeviceProxy
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

  def timestamp
    Time.now.to_i.to_s
  end

  def action(name)
    "http://global.samsungsmartappliance.com/Device/#{name}?_=#{timestamp}"
  end

  def getDeviceState()
    result = RestClient.get(action('getDeviceState'))
    
    Nokogiri::XML(result)
  end 
end

class Samsung::Web::CommunicationProxy
  def timestamp
    Time.now.to_i.to_s
  end

  def action(name)
    "http://global.samsungsmartappliance.com/Communication/#{name}?_=#{timestamp}"
  end

  #
  # Execute a 'selectDevice' call, returning the capabilities of the air conditioner.
  #
  # This appears to be the kind of file a UPnP discovery would look for too.
  #
  def selectDevice(headers)
    result = RestClient.get(action('selectDevice'), headers)
    
    Nokogiri::XML(result)
  end

  def getDeviceState(headers)
    result = RestClient.get(action('getDeviceState'))
    
    Nokogiri::XML(result)
  end

  #
  # Sends a command to the device.
  #
  # Response will include a CommandId, which can be polled for success via checkControl()
  #
  def setControl(xml, headers)
    result = RestClient.post(action('setControl'), xml, headers.merge({:content_type => 'text/xml'}))

    Nokogiri::XML(result)
  end

  #
  # Poll for the status of a previously sent command.
  #
  # <rsp stat="ok"><ControlResult DUID="...">Processing</ControlResult></rsp>
  # <rsp stat="ok"><ControlResult DUID="...">Success</ControlResult></rsp>
  #
  def checkControl(id, headers)
   result = RestClient.get(action('checkControl'), headers.merge({'CommandId' => id}))

    Nokogiri::XML(result) 
  end

end

# A particular air conditioner
class Samsung::Web::Boracay
  def initialize(communication_proxy, headers)
    @communication_proxy = communication_proxy
    @headers = headers
  end

  def control
    @communication_proxy.selectDevice(@headers)
  end

  def on     
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="' + timestamp + '"><Device><Status Power="On" /></Device></ControlCommand>', @headers)
  end

  def off
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="' + timestamp + '"><Device><Status Power="Off" /></Device></ControlCommand>', @headers)    
  end

  def timestamp
    Time.now.to_i.to_s
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
    mode = type.capitalize
    modes = ['Auto', 'Cool', 'Dry', 'Wind', 'Heat']
    if modes.index(mode) == nil
      raise "Invalid operation mode, " + mode + " is not one of " + modes.inspect
    end
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="' + timestamp + '"><Device><Status OperationMode="' + mode + '" /></Device></ControlCommand>', @headers)    
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
    headers = {}
    headers['Accept'] = @headers['accept']
    headers['Cookie'] = @headers['cookie']
    headers['Origin'] = 'http://global.samsungsmartappliance.com'
    headers['Referer'] = 'http://global.samsungsmartappliance.com/'
    headers['X-Requested-With'] = 'XMLHttpRequest'
    headers["Content-Type"] = 'text/xml'

    @communication_proxy.setControl('<ControlCommand LastUpdateTime="' + timestamp + '" ><Device><Status TempSet="' + temp.to_i.to_s + '" /></Device></ControlCommand>', headers)      
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

  def info
    @communication_proxy.getDeviceState(@headers)
  end
end

class Authenticator
  #
  # Login with a configured Mechanize agent to obtain a session cookie
  #
  def login(agent, user, pass, service_id)
    login_page = agent.post('https://account.samsung.com/account/check.do', {
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

    login_page.form['inputUserID'] = user
    login_page.form['inputPassword'] = pass
    login_page.form['serviceID'] = service_id
    login_page.form['remIdCheck'] = 'on'
    login_page.form.action = 'https://account.samsung.com/account/startSignIn.do'

    start_sso = login_page.form.submit
    finish_sso = start_sso.form.submit

    agent.cookies
  end
end

class Samsung::Physical::Authenticator
  def initialize(ssl_client, log)
    @ssl_client = ssl_client
    @log = log
  end

  def login
    @ssl_client.connect

    # Discard the first two lines
    # DRC-1.00
    read
    # <?xml version="1.0" encoding="utf-8" ?><Update Type="InvalidateAccount"/>
    read


    if send('<Request Type="GetToken" />').xpath('//Response[@Type="GetToken" and @Status="Ready"]').first
      output "Go power on your air con in the next 30 seconds"
    end

    response = Nokogiri::XML(read())
    if response.xpath('//Response[@Status="Fail"]').first
      output "Too slow!"
    end

    if response.xpath('//Update[@Type="GetToken"]').first
      output 'Hurray, your token is:'
      output response.xpath('//Update/@Token').first.value

      return response.xpath('//Update/@Token').first.value
    end
  end        
  
  def read
    line = nil
    while line == nil
      line = @ssl_client.gets
    end
    @log.info("Reading: #{line}")

    line
  end

  def send(xml)
    @log.info("Sending: #{xml}")
    @ssl_client.puts xml
    
    Nokogiri::XML(read())
  end

  def output(text)
    puts text
  end
end
     



class Samsung::Physical::Boracay
  def initialize(ssl_client, config, log)
    @ssl_client = ssl_client
    @config = config
    @log = log
  end

  def send(xml)
    @log.info("Sending: #{xml}")
    @ssl_client.puts xml

    line = @ssl_client.gets
    @log.info("Reading: #{xml}")
    Nokogiri::XML(line)
  end

  def login!
    @ssl_client.connect

    @log.info(@ssl_client.gets)
    @log.info(@ssl_client.gets)

    xml = %Q{<Request Type="AuthToken"><User Token="#{@config['token']}" /></Request>}
    response = send(xml).xpath('//Response[@Type="AuthToken"]/@Status').first.value

    return response == "Okay"
  end

  def device_control(key, value)
    send(%Q{<Request Type="DeviceControl"><Control CommandID="cmd#{rand(10000)}" DUID="#{@config["duid"]}"><Attr ID="#{key}" Value="#{value}" /></Control></Request>})
  end

  def on     
    device_control('AC_FUN_POWER', 'On')
  end

  def off
    device_control('AC_FUN_POWER', 'Off')
  end

  def operation_mode(type)
    mode = type.capitalize
    modes = ['Auto', 'Cool', 'Dry', 'Wind', 'Heat']
    if modes.index(mode) == nil
      raise "Invalid operation mode, " + mode + " is not one of " + modes.inspect
    end

    device_control('AC_FUN_OPMODE', mode)
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
        #     AC_FUN_TEMPSET => {
        #         english => 'Set temperature',
        #         min => 16,
        #         max => 30,
        # },
    device_control('AC_FUN_TEMPSET', temp.to_i.to_s)
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
  def set_convient_mode(mode)
    mode = type.capitalize
    modes = ['Off', 'Quiet', 'Sleep', 'Smart', 'SoftCool', 'TurboMode', 'WindMode1', 'WindMode2', 'WindMode3']
    if modes.index(mode) == nil
      raise "Invalid operation mode, " + mode + " is not one of " + modes.inspect
    end    
    
    device_control('AC_FUN_COMODE', mode)
  end

  def get_temperature
    device_control('AC_FUN_TEMPNOW', '')
  end

  def sleep_mode(hours)
    device_control('AC_FUN_SLEEP', hours)
  end

  def wind_level(mode)
    mode = type.capitalize
    modes = ['Auto', 'Low', 'Mid', 'High', 'Turbo']
    if modes.index(mode) == nil
      raise "Invalid operation mode, " + mode + " is not one of " + modes.inspect
    end    

    device_control('AC_FUN_WINDLEVEL', hours)
  end

  def wind_level(mode)
    mode = type.capitalize
    modes = [
      'Center', 
      'Direct', 
      'Fixed', 
      'Indirect', 
      'Left', 
      'Long', 
      'Off', 
      'Right', 
      'Rotation', 
      'SwingLR', 
      'SwingUD', 
      'Wide'
    ]

    if modes.index(mode) == nil
      raise "Invalid operation mode, " + mode + " is not one of " + modes.inspect
    end    

    device_control('AC_FUN_DIRECTION', mode)
  end

   def autoclean(mode)
    mode = type.capitalize
    modes = [
      'On',
      'Off'
    ]

    if modes.index(mode) == nil
      raise "Invalid operation mode, " + mode + " is not one of " + modes.inspect
    end    

    device_control('AC_ADD_AUTOCLEAN', mode)
  end
end