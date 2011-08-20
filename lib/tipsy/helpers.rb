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
    
    def self._register_local(klass)
      module_names = []
      includes = Dir.glob(File.expand_path(Tipsy.root) << "/helpers/*.rb").inject([]) do |arr, helper|
        module_names << File.basename(helper, '.rb').classify
        arr.concat File.open(helper).readlines          
      end
      module_names.each{ |mod| includes.concat(["\n include #{mod}"]) }
      klass.class_eval(includes.join("\n"))
    end
    
  end
end