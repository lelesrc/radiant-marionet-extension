# encoding: utf-8
#--
# (c) Copyright 2010 Mikael Lammentausta
#
# See the file LICENSE included with the distribution for
# software license details.
#++
require 'nokogiri'
require 'singleton'

# Singleton class that performs XSL transformation to the HTML.
class Marionet::Parser
  include Singleton
  
  @@namespace = 'http://github.com/youleaf/rails-marionet'
  attr_reader :stylesheets
  
  # Loads the XSL files from disk to memory.
  # Singleton takes care they are read only once.
  def initialize()
    @stylesheets = { 
      :body => Nokogiri::XSLT( File.read( File.join( File.dirname(__FILE__),'xsl',
        'body.xsl'))),
      :test => Nokogiri::XSLT( File.read( File.join( File.dirname(__FILE__),'xsl',
        'test.xsl')))
    }
  end
  
=begin
  # link
  XML::XSLT.registerExtFunc(@@namespace, 'link') do |nodes,session|
    #logger.debug('link transformation')
    #logger.debug(session)
    nodes.each do |node|
      #logger.debug(node)
      href = node.attributes['href']
      unless href
        next
      end
      
      if session[0].attributes['baseURL']
        pass
        # XXX: rewrite base
      end
      
      #url = Portlet::Url.render_url()
      url = 'http://new-url'
      
      node.attributes['href'] = url
    end
    nodes
  end
  
  # image
  
  # href
  
  # form
=end

  def logger # :nodoc:
    Marionet.logger
  end

  class << self

    # Perform XSL transformation on the html (Nokogiri::XML).
    # XXX: append session to the document
    def transform(doc, session=nil, stylesheet=:body)
      xslt = self.instance.stylesheets[stylesheet]
      xslt.transform(doc)
    end

    def logger # :nodoc:
      Marionet.logger
    end

  end
end