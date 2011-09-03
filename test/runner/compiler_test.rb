require 'test_helper'

class CompilerTest < ActiveSupport::TestCase
  attr_reader :compiler
  
  def setup
    Tipsy::Runners::Compiler.send(:include, Tipsy::Utils::SystemTest)
    @compiler = Tipsy::Runners::Compiler.new
    Tipsy::Site.configure!
  end
  
  test "Ensure source path is set" do
    compiler.source_path.should == Tipsy::Site.config.public_path    
  end
  
  test "Ensure destination path is set" do
    compiler.dest_path.should == Tipsy::Site.config.compile_to
  end
  
  test "An option exists to skip specific files and folders on compile" do
    compiler.excludes.include?('.git').should == true
    compiler.excludes.include?('.svn').should == true
  end
  
  test "Ensure skipped directory is not removed" do
    compiler.was_deleted?(File.join(Tipsy::Site.compile_to, ".svn")).should == false
  end
  
  test "Ensure un-skipped files are removed" do
    compiler.was_deleted?(File.join(Tipsy::Site.compile_to, "sub-path-with-skip", "fake.txt")).should == true
  end
  
  test "Ensure un-skipped files in folders are removed" do
    compiler.was_deleted?(File.join(Tipsy::Site.compile_to, "sub-path", "fake.txt")).should == true
  end
  
  test "Ensure un-skipped directories are removed" do
    compiler.was_deleted?(File.join(Tipsy::Site.compile_to, "sub-path")).should == true
  end
  
end