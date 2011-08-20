require 'hike'
require 'tilt'
require 'tipsy/view/errors'

module Tipsy
  class View
    attr_reader :view_path, :request
    
    def initialize(path, req)
      @view_path = path
      @request   = req
    end
    
    def view_context
      @_view_context ||= Class.new(self)
        include Tipsy::Helpers
      end.class_eval(_register_helpers)
    end
    
    private
    
    def template
      @_template ||= 
    end
    
    def _register_helpers
      module_names = []
      includes = Dir.glob(File.expand_path(Tipsy.root) << "/helpers/*.rb").inject([]) do |arr, helper|
        module_names << File.basename(helper, '.rb').classify
        arr.concat File.open(helper).readlines          
      end
      module_names.each{ |mod| includes.concat(["\n include #{mod}"]) }
      includes.join("\n")
    end
    
  end
end