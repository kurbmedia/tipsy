require 'test_helper'

class SystemTest < ActiveSupport::TestCase
  attr_reader :runner
  
  class Runner
    include Tipsy::Utils::System
  end

  def setup
    @runner = Runner.new
  end

  test "Files can be excluded by extension" do
    runner.excluded?("/home/someuser/another/something.rb").should == true    
  end
  
  test "Entire directories can be excluded" do
    runner.excluded?("/home/someuser/another/.svn").should == true    
  end
  
  test "Non-excluded directories should be found" do
    runner.excluded?("/home/someuser/another/something/").should == false
  end
  
end