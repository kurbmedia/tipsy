require 'test_helper'

class PageTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Tipsy::Test::Helpers

  def app
    Tipsy::Test.app
  end

  def test_the_home_page_is_successful
    get "/"    
    assert last_response.ok?
  end
  
  def test_the_home_page_renders_index
    get "/"
    to_html(last_response.body).should == fixture('index.html')
  end
  
  def test_the_about_page_renders_about
    get '/about'
    assert last_response.ok?
    to_html(last_response.body).should == fixture('about.html')
  end
  
  def test_find_page_above_folder
    get '/contact'
    assert last_response.ok?
    to_html(last_response.body).should == fixture('contact.html')
  end

end