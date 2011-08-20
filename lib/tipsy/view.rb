require 'tilt'
require 'tipsy/helpers'
require 'hike'

module Tipsy
  ##
  # Handles rendering of templates and layouts
  # 
  class View

    attr_reader :content_type
    attr_reader :file
    attr_reader :trail
    attr_reader :view_path

    attr_accessor :request
    
    def initialize(path)            
      @content_type = 'text/html'
      @trail        = Hike::Trail.new(File.join(Tipsy.root, 'views'))      
      @view_path    = path
      @template     = nil      
      trail.append_path('.')
      trail.append_extensions '.erb','.html', '.json', '.xml'      
    end
    
    def render
      unless template.nil?
        handler  = Tilt[template]
        tilt     = handler.new(template, nil, :outvar => '@_output_buffer')
        context  = Context.new(request, template, trail)
        contents = tilt.render(context);
        
        unless layout.nil?
          wrapped  = Tilt.new(layout, nil, :outvar => '@_output_buffer')          
          # Remap provided locals
          locals  = context.send(:instance_variables).inject({}) do |hash, var|
            hash.merge!(var.to_s.sub("@", '') => context.send(:instance_variable_get, var))
          end
          contents = wrapped.render(context, locals) do |*args|
            contents
          end
        else
          tilt.render(context)
        end
        return contents
      end      
      nil
    end
    
    private
    
    def template
      @template ||= (trail.find(view_path) || trail.find(File.join(view_path, "index")))
    end
    
    def layout
      @layout ||= (trail.find(File.join(view_path, '_layout')) || trail.find('_layout'))
    end
    
    ##
    # A rendering context. This class is the context all views are stemmed from.
    # 
    class Context
      include Tipsy::Helpers
      attr_reader :request, :root, :template_file_name, :view_trail
      
      def initialize(req, tpl, trail)
        @request            = req
        @root               = Tipsy.root
        @template_file_name = tpl
        @view_trail         = trail
        __initialize_helpers
      end
    end
    
  end
end

begin
  require 'erubis'
  Tilt.prefer Tilt::ErubisTemplate, 'erb'
rescue LoadError
end