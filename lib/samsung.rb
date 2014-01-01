require 'nokogiri'
require 'rest_client'
require 'mechanize'
require 'yaml'

require 'nokogiri'
require 'yaml'
require 'logger'
require 'openssl'
require 'logger'

module Samsung
  module Web
  end
  module Physical
  end
end

require File.dirname(__FILE__) + '/physical/authenticator'
require File.dirname(__FILE__) + '/physical/boracay'

require File.dirname(__FILE__) + '/web/authenticator'
require File.dirname(__FILE__) + '/web/device_proxy'
require File.dirname(__FILE__) + '/web/communication_proxy'
require File.dirname(__FILE__) + '/web/boracay'

