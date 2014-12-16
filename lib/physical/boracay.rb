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
    @log.info("Reading: #{line}")
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

  def get_status
    send(%Q{<Request Type="DeviceState" DUID="#{@config["duid"]}"></Request>})
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