require 'test_helper'
require 'tipsy/view'

class ViewPathTest < ActiveSupport::TestCase
  attr_reader :path
  
  def setup
    @path ||= Tipsy::View::Path.new
  end

  test "The default template should be index" do
    path.locate_template('').should_not == nil
  end
  
  test "Pages should be found by path" do
    path.locate_template("page").should_not == nil
  end  
  
  test "The default layout should be found" do
    path.locate_layout('default').should == expand_path('layouts', 'default.html.erb')
  end
  
  test "Templates should be found by URI if existing" do
    path.locate_template('page').should == expand_path('views', 'page.html.erb')
  end
  
  private
  
  def expand_path(*names)
    names.unshift(Tipsy.root)
    File.join(*names)
  end

end