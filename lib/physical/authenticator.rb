
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
   