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
