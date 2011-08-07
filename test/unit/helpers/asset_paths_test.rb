require 'test_helper'

class AssetPathsTest < Test::Unit::TestCase
  include Tipsy::Helpers
  
  def test_asset_path_helper
    asset_path("something.js").should == '/assets/something.js'
  end
  
  def test_absolute_asset_path
    asset_path("/js/something.js").should == '/js/something.js'
  end

end