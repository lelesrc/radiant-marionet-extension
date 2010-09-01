# encoding: utf-8
#--
# (c) Copyright 2010 Mikael Lammentausta
#
# See the file LICENSE included with the distribution for
# software license details.
#++
require 'rexml/document'
require 'xml/xslt'
require 'singleton'

# Singleton class that performs XSL transformation to the HTML.
class Marionet::Parser
  include Singleton
  include REXML
  
  @@namespace = 'http://github.com/youleaf/rails-marionet'
  attr_reader :stylesheets
  
  # Loads the XSL files from disk to memory.
  # Singleton takes care they are read only once.
  def initialize()
    body = Document.new( File.new( File.join(
      File.dirname(__FILE__),'xsl','body.xsl')))
    test = Document.new( File.new( File.join(
      File.dirname(__FILE__),'xsl','test.xsl')))
    @stylesheets = { 
      :body => body,
      :test => test
    }
  end
  
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

  # Creates a new transformer instance, from the static list of cached stylesheets.
  def transformer_impl(stylesheet)
    impl = XML::XSLT.new()
    impl.xsl = @stylesheets[ stylesheet ]
    return impl
  end

  def logger # :nodoc:
    Marionet.logger
  end

  class << self

    # Perform XSL transformation on the html (REXML::Document) or (String),
    # with the marionet portlet session (Marionet::Session).
    # Session is a REXML::Element 'portlet-session'.
    def transform(doc, session=nil, stylesheet=:body)
      #logger.debug self.instance.transformer
      # create copy of the transformer attribute from instance. 
      transformer = self.instance.transformer_impl(stylesheet)
      logger.debug transformer

      # append session to the document
      head = XPath.first(doc,'//html')
      if head and session
        head << session.element
      end

      # prepare transformer with document
      transformer.xml = doc

      transformer.serve()
    end

    def logger # :nodoc:
      Marionet.logger
    end

  end
end