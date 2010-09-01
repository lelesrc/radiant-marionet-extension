# encoding: utf-8
#--
# (c) Copyright 2010 Mikael Lammentausta
#
# See the file LICENSE included with the distribution for
# software license details.
#++
class Marionet
  
  attr_reader :data
  
  def initialize(uri)
    logger.debug 'new marionet: %s' % uri
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")  # enable SSL/TLS
    result = http.request_get(uri.path + '?' + uri.query).body
    logger.debug("Webservice response:\n#{result}")
    @data = Nokogiri::XML.parse(result)
  end
  
  def logger
    RAILS_DEFAULT_LOGGER
  end
  
end