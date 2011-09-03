require 'test_helper'

class TipsyTest < ActiveSupport::TestCase

  test "A root method is defined, defaulting to ENV['TIPSY_ROOT']" do
    assert_equal Tipsy.root, File.expand_path("../../", __FILE__) << "/root"
  end
  
  test "An env method is defined, defaulting to ENV['TIPSY_ENV']" do
    assert_equal Tipsy.env, "test"
  end
  
end