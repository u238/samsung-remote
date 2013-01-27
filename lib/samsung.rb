module Samsung

  class DeviceProxy
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

  class CommunicationProxy
    #
    # Execute a 'selectDevice' call, returning the capabilities of the air conditioner.
    #
    # This appears to be the kind of file a UPnP discovery would look for too.
    #
    def selectDevice()
      result = RestClient.get('http://global.samsungsmartappliance.com/Communication/selectDevice?_=1359113706632')
      
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
end