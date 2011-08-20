require 'hike'
require 'tilt'
require 'tipsy/view/errors'

module Tipsy
  class View
    include Tipsy::Logging
    
    attr_reader :view_path, :request
    attr_internal :contents
    
    def initialize(path, req)
      @view_path = path
      @view_path = "." if path.to_s.blank?
      @request   = req
    end
    
    def view_context
      @_view_context ||= Context.new(request)
    end
    
    def render
      raise TemplateMissing.new("Could not find a template for path #{view_path}") and return if _template.nil?
      return nil unless _template      
      
      handler  = Tilt[_template]
      tilt     = handler.new(_template, nil, :outvar => '@_output_buffer')
        
      benchmark("Rendered #{_template.sub(Tipsy.root, '')}") do
        @contents = tilt.render(view_context)
      end
      raise LayoutMissing.new("Missing layout '#{view_context.layout}'") and return if _layout.nil?
        
      if _layout
        wrapped  = Tilt[_layout].new(_layout, nil, :outvar => '@_output_buffer')          
        benchmark("Rendered #{_layout.sub(Tipsy.root, '')}") do
          @contents = wrapped.render(view_context) do |*args|
            @contents
          end
        end          
      end
      logger.info("")
      @contents
    end
    
    private
    
    def _layout
      return false if view_context.layout.nil? || view_context.layout === false
      @_layout ||= Finder.new('layouts').find(view_context.layout)
    end
    
    def _lookup_context
      @_lookup_context ||= Finder.new
    end

    def _template
      @_template ||= (_lookup_context.find(view_path) || _lookup_context.find(File.join(view_path, "index")))
    end
    
    class Context
      include Tipsy::Helpers
      attr_reader :request
      
      def initialize(req)
        @request = req
        @layout  = 'default'
        Tipsy::Helpers._register_local(self)
      end
      
      def layout(set = nil)
        return @layout unless set
        @layout = set
        nil
      end
    end
    
    class Finder
      attr_accessor :trail
      def initialize(base = 'views')
        @trail = Hike::Trail.new(File.join(Tipsy.root, base))
        @trail.append_path('.')
        @trail.append_extensions '.erb','.html', '.json', '.xml'
      end
      delegate :find, :to => :trail
    end
    
  end
end

begin
  require 'erubis'
  Tilt.prefer Tilt::ErubisTemplate, 'erb'
rescue LoadError
end