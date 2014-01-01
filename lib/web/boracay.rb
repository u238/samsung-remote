# A particular air conditioner
class Samsung::Web::Boracay
  def initialize(communication_proxy, config, cookie)
    @communication_proxy = communication_proxy


  end

  def control
    @communication_proxy.selectDevice
  end

  def on     
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="' + timestamp + '"><Device><Status Power="On" /></Device></ControlCommand>')
  end

  def off
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="' + timestamp + '"><Device><Status Power="Off" /></Device></ControlCommand>')    
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
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="' + timestamp + '"><Device><Status OperationMode="' + mode + '" /></Device></ControlCommand>')    
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
    @communication_proxy.setControl('<ControlCommand LastUpdateTime="' + timestamp + '" ><Device><Status TempSet="' + temp.to_i.to_s + '" /></Device></ControlCommand>')      
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
    @communication_proxy.getDeviceState()
  end
end