require File.dirname(__FILE__) + '/test_helper'
require 'nokogiri'
require 'sanitize'

class HttpclientTest < Test::Unit::TestCase
  
  def setup
    @junit_url = 'http://127.0.0.1:3000/caterpillar/test_bench/junit'
  end
  
  def teardown
    # Nothing really
  end
  
  def test_get
    # SIMPLE GET
    client = HTTPClient.new
    assert client
  
    assert_equal(0, client.cookie_manager.cookies.size)
    
    response = client.get(@junit_url)
    assert_equal(200, response.status_code)
    
    assert_equal(0, client.cookie_manager.cookies.size)
    
  end
  
  def test_get_cookie
    # COOKIE AND SESSION TEST
    client = HTTPClient.new
    assert client
  
    assert_equal(0, client.cookie_manager.cookies.size)
    
    session_id = nil
    
    url = @junit_url+'/session_cookie'
    
    response = client.get(url)
    assert_equal(200, response.status_code)
    
    cookies = client.cookie_manager.cookies.dup
    assert_equal(1, cookies.length)
    
    xml = response.content
    doc = Nokogiri::XML(xml)
    assert(doc)
    
    nodes = doc.xpath('//id/text()')
    assert_equal(1, nodes.length)
    
    session_id = nodes[0].content
    assert(session_id)
    
    # GET again and assert that the session remains the same
    xml = doc = nodes = response = client = nil
    
    client = HTTPClient.new
    assert client
  
    assert_equal(0, client.cookie_manager.cookies.size)
    cookies.each {|cookie| client.cookie_manager.add(cookie)}

    assert_equal(1, client.cookie_manager.cookies.size)
            
    response = client.get(url)
    assert_equal(200, response.status_code)
    
    xml = response.content
    doc = Nokogiri::XML(xml)
    assert(doc)
    
    nodes = doc.xpath('//id/text()')
    assert_equal(1, nodes.length)
    
    _session_id = nodes[0].content
    assert_equal(session_id,_session_id)
    
  end
  
  def test_post_redirection
    # TEST POST + REDIRECTION
    client = HTTPClient.new
    assert client
  
    assert_equal(0, client.cookie_manager.cookies.size)
        
    url = @junit_url+'/post_redirect_get'
    
    #status code 
    #POST doesn't redirect
    response = client.post(url)
    assert_equal(302, response.status_code)
    assert_equal(0, client.cookie_manager.cookies.size)
    
    #redirection
    #POST_CONTENT doesn't return header
    response = client.post_content(url)
    assert_equal('/caterpillar/test_bench/junit/redirect_target', response)
  end
  
  def test_post_params
    # TEST POST + PARAMS
    client = HTTPClient.new
    assert client
  
    assert_equal(0, client.cookie_manager.cookies.size)
        
    url = @junit_url+'/post_params'
    params = {'foo' => 'bar', 'baz' => 'xyz'}
    response = client.post(url,params)
    
    assert_equal(200, response.status_code)
    assert_equal(0, client.cookie_manager.cookies.size)
    
    xml = response.content
    doc = Nokogiri::XML(xml)
    assert(doc)
    
    for key,value in params do
      n = doc.xpath('//'+ key)
      assert (n)
      assert_equal(value,n[0].content)
    end
  end
  
  def test_post_cookies
    # TEST POST REDIRECT + PRESET COOKIES
    client = HTTPClient.new
    assert client
  
    assert_equal(0, client.cookie_manager.cookies.size)
        
    url = @junit_url+'/post_cookies'
    
    cookie1 = WebAgent::Cookie.new
    host1 = URI::HTTP.build({:userinfo => "blabla", :host => "127.0.0.1" , :port => "3000", :path => "/post_cookies", :query => "", :fragment => ""})
    cookie1.url = host1
    cookie1.name = "foo"
    cookie1.value = "bar"
    assert cookie1
    
    cookie2 = WebAgent::Cookie.new
    cookie2.url = host1
    cookie2.name = "baz-baz"
    cookie2.value = Time.now.to_date.to_s
    assert cookie2
    
    client.cookie_manager.add(cookie1)
    assert_equal(1, client.cookie_manager.cookies.size)
    client.cookie_manager.add(cookie2)
    assert_equal(2, client.cookie_manager.cookies.size)
    
    response = client.post_content(url)
    assert_equal(3, client.cookie_manager.cookies.size)
    
    xml = response
    doc = Nokogiri::XML(xml)
    assert(doc)
    
    client.cookie_manager.cookies.each do |cookie|
      key = cookie.name
      value = cookie.value

      n = doc.xpath('//'+ key)

      assert(n)
      #assert(n.size > 0, "COOKIE #{key} NOT FOUND")
      #assert_equal(value,n[0].content, "COOKIE #{key} HAS DIFFERENT VALUE")
    end
  end
  
  def test_server_cookies
    # TEST SERVER COOKIES
    client = HTTPClient.new
    assert client
  
    assert_equal(0, client.cookie_manager.cookies.size)
        
    url = @junit_url+'/foobarcookies'
    
    response = client.post(url)
    assert_equal(200, response.status)
    # server sends three cookies
    assert_equal(3, client.cookie_manager.cookies.size)
    
    # then head to a new url
    url = @junit_url+'/foobarcookiestxt'
    response = client.post_content(url)
    #self.assertEqual(200, response.status)
    assert_equal('__g00d____yrcl____3ver__',response)
  end
 
  def test_sanity
    #CLIENT 1
    client_1 = HTTPClient.new
    assert client_1
  
    assert_equal(0, client_1.cookie_manager.cookies.size)
    
    cookie1 = WebAgent::Cookie.new
    host1 = URI::HTTP.build({:userinfo => "blabla", :host => "127.0.0.1" , :port => "3000", :path => "/post_cookies", :query => "", :fragment => ""})
    cookie1.url = host1
    cookie1.name = "foo"
    cookie1.value = "bar"
    assert cookie1
    
    cookie2 = WebAgent::Cookie.new
    cookie2.url = host1
    cookie2.name = "baz"
    cookie2.value = "xyz"
    assert cookie2
    
    client_1.cookie_manager.add(cookie1.dup)
    assert_equal(1, client_1.cookie_manager.cookies.size)
    client_1.cookie_manager.add(cookie2.dup)
    assert_equal(2, client_1.cookie_manager.cookies.size)

    #CLIENT 2
    client_2 = HTTPClient.new
    assert client_2
  
    assert_equal(0, client_2.cookie_manager.cookies.size)
    
    host1 = URI::HTTP.build({:userinfo => "blabla", :host => "127.0.0.1" , :port => "3000", :path => "/post_cookies", :query => "", :fragment => ""})
    cookie1 = WebAgent::Cookie.new
    cookie1.url = host1
    cookie1.name = "foo"
    cookie1.value = "bar"
    assert cookie1
    
    cookie2 = WebAgent::Cookie.new
    cookie2.url = host1
    cookie2.name = "baz"
    cookie2.value = "xyz"
    assert cookie2
    
    cookie3 = WebAgent::Cookie.new
    cookie3.url = host1
    cookie3.name = "pippo"
    cookie3.value = "pluto"
    assert cookie3
    
    client_2.cookie_manager.add(cookie1.dup)
    assert_equal(1, client_2.cookie_manager.cookies.size)
    client_2.cookie_manager.add(cookie2.dup)
    assert_equal(2, client_2.cookie_manager.cookies.size)
    client_2.cookie_manager.add(cookie3.dup)
    assert_equal(3, client_2.cookie_manager.cookies.size)

    assert_equal(2, client_1.cookie_manager.cookies.size)
  end
end
