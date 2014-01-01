require 'rubygems'
require "bundler/setup"
require './lib/samsung'

require 'nokogiri'
require 'rest_client'

require 'yaml'

require 'logger'
require 'openssl'

config = YAML.load_file('settings.yml')
#log = Logger.new "output.log"
log = Logger.new STDOUT

require 'socket'

context = OpenSSL::SSL::SSLContext.new
tcp_client = TCPSocket.new config['ip'], 2878
ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, context



class Samsung::PhysicalAuthenticator
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
     

unless config['token']
  auth = Samsung::PhysicalAuthenticator.new(ssl_client, log)
  config['token'] = auth.login
end


# RestClient.log = log
# headers = {}
# headers['master_duid'] = ""
# headers['duid'] = config['duid']
# headers['accept'] = 'application/xml, text/xml, */*; q=0.01'
# headers['cookie'] = options[:cookie]

# proxy = Samsung::CommunicationProxy.new
# boracay = Samsung::Boracay.new(proxy, headers)
# boracay.control()

# boracay.on()
# sleep(10)
# boracay.operation_mode('Cool')
# sleep(10)
# boracay.set_temperature(22)
# sleep(20)
# boracay.off()