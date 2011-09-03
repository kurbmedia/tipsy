require 'test_helper'

class SiteTest < ActiveSupport::TestCase

  def setup
    Tipsy::Site.configure!
  end

  test "before_compile should be a callable class method" do
    Tipsy::Site.respond_to?(:before_compile).should == true
  end
  
  test "Defined callbacks should be runnable blocks" do
    check = false
    Tipsy::Site.before_compile do
      check = true
    end
    Tipsy::Site.before_compile
    check.should == true
  end
  

end