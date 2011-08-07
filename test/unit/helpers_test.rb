require 'test_helper'

class HelpersTest < Test::Unit::TestCase
  include Tipsy::Helpers
  
  def test_tag_helper
    tag(:img, :src => 'test.png').should == '<img src="test.png" />'
  end
  
  def test_content_tag_helper
    content_tag(:p, 'hello', :class => 'test').should == '<p class="test">hello</p>'
  end
  
  def test_link_to_helper
    link_to('link', '/home').should == '<a href="/home">link</a>'
  end
  
  def test_mail_to_helper
    mail_to('test@test.com').should == '<a href="mailto:test@test.com">test@test.com</a>'
  end
  
end