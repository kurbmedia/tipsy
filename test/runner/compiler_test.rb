require 'test_helper'

class CompilerTest < ActiveSupport::TestCase
  attr_reader :compiler
  
  def setup
    Tipsy::Runners::Compiler.send(:include, Tipsy::Utils::SystemTest)
    Tipsy::Utils::Tree.send(:include, Tipsy::Utils::SystemTest)
    @compiler = Tipsy::Runners::Compiler.new
    Tipsy::Site.configure!
  end
  
  test "Ensure source path is set" do
    compiler.source_path.should == Pathname.new(Tipsy::Site.config.public_path)    
  end
  
  test "Ensure destination path is set" do
    compiler.dest_path.should == Pathname.new(Tipsy::Site.config.compile_to)
  end
  
  test "An option exists to skip specific files and folders on compile" do
    compiler.excludes.include?('.git').should == true
    compiler.excludes.include?('.svn').should == true
  end
  
  test "Ensure skipped directory is not removed" do
    compiler.was_deleted?(File.join(Tipsy::Site.compile_to, ".svn")).should == false
  end
   
  test "Ensure templates are created" do
    compiler.was_created?(File.join(Tipsy::Site.compile_to, "sub", "page.html")).should == true
  end
  
  test "Ensure index templates are created" do
    compiler.was_created?(File.join(Tipsy::Site.compile_to, "sub", "tertiary", "index.html")).should == true
  end
  
end