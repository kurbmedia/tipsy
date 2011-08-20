require 'active_support/core_ext/array'

require 'tipsy/helpers/asset_paths'
require 'tipsy/helpers/capture'
require 'tipsy/helpers/tag'
require 'tipsy/helpers/asset_tags'
require 'tipsy/helpers/sass'

module Tipsy
  module Helpers
    include Capture
    include Tag 
    include AssetPaths
    include AssetTags
  end
end