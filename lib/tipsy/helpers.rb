require 'active_support/core_ext/array'
require 'tipsy/helpers/asset_paths'
require 'tipsy/helpers/capture'
require 'tipsy/helpers/tag'
require 'tipsy/helpers/asset_tags'
require 'tipsy/helpers/rendering'

module Tipsy
  module Helpers
    include Capture
    include Tag 
    include AssetPaths
    include AssetTags
    include Rendering
    
    extend ActiveSupport::Concern
    
    included do
      module_names = []
      includes = Dir.glob(File.expand_path(Tipsy.root) << "/helpers/*.rb").inject([]) do |arr, helper|
        module_names << File.basename(helper, '.rb').classify
        arr.concat File.open(helper).readlines          
      end
      module_names.each{ |mod| includes.concat(["\n include #{mod}"]) }
      eval(includes.join("\n"), binding)
    end    
  end
  
end