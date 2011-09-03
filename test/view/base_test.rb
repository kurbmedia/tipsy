require 'test_helper'
require 'tipsy/view'

class ViewBaseTest < ActiveSupport::TestCase
  attr_reader :path
  
  def setup
    @path ||= Tipsy::View::Path.new
  end

  test "It should find a default index template" do
    path.locate_template('').should_not == nil
  end
  
  test "It should locate templates based on the path" do
    path.locate_template("page").should_not == nil
  end  
  
  test "Locating the default layout" do
    path.locate_layout('default').should == expand_path('layouts', 'default.html.erb')
  end
  
  test "Template is found from the URI" do
    path.locate_template('page').should == expand_path('views', 'page.html.erb')
  end
  
  private
  
  def expand_path(*names)
    names.unshift(Tipsy.root)
    File.join(*names)
  end

end