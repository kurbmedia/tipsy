require 'test_helper'
require 'tipsy/helpers'

class TagTest < ActiveSupport::TestCase

  include Tipsy::Helpers::Tag
  include Tipsy::Helpers::AssetPaths
  include Tipsy::Helpers::AssetTags
  
  def setup
    @output_buffer = ""
  end

  test "Single tags should be rendered with attributes" do
    tag(:img, { src: "some/source.jpg" }).should  == '<img src="some/source.jpg" />'
  end
  
  test "The image_tag renders an img tag" do
    image_tag("something.jpg").should == '<img alt="something.jpg" src="/assets/something.jpg" />'
  end

end