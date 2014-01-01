class Samsung::Web::CommunicationProxy
  def initialize(config)
    headers = {}
    headers['master_duid'] = ""
    headers['duid'] = config['duid']
    headers['accept'] = 'application/xml, text/xml, */*; q=0.01'
    headers['cookie'] = cookie

    headers['Accept'] = headers['accept']
    headers['Cookie'] = headers['cookie']    
    headers['Origin'] = 'http://global.samsungsmartappliance.com'
    headers['Referer'] = 'http://global.samsungsmartappliance.com/'
    headers['X-Requested-With'] = 'XMLHttpRequest'
    headers["Content-Type"] = 'text/xml'

    @headers = headers
  end
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
  def selectDevice
    result = RestClient.get(action('selectDevice'), @headers)
    
    Nokogiri::XML(result)
  end

  def getDeviceState
    result = RestClient.get(action('getDeviceState'), @headers)
    
    Nokogiri::XML(result)
  end

  #
  # Sends a command to the device.
  #
  # Response will include a CommandId, which can be polled for success via checkControl()
  #
  def setControl(xml)
    result = RestClient.post(action('setControl'), xml, @headers.merge({:content_type => 'text/xml'}))

    Nokogiri::XML(result)
  end

  #
  # Poll for the status of a previously sent command.
  #
  # <rsp stat="ok"><ControlResult DUID="...">Processing</ControlResult></rsp>
  # <rsp stat="ok"><ControlResult DUID="...">Success</ControlResult></rsp>
  #
  def checkControl(id, headers)
   result = RestClient.get(action('checkControl'), @headers.merge({'CommandId' => id}))

    Nokogiri::XML(result) 
  end

end