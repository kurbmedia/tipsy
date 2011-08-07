require 'tilt'
require 'tipsy/helpers'
require 'hike'

module Tipsy
  class View

    attr_reader :content_type
    attr_reader :file
    attr_reader :request
    attr_reader :trail
    attr_reader :view_path
    
    def initialize(path, request)            
      @request      = request
      @content_type = 'text/html'
      @trail        = Hike::Trail.new(File.join(Tipsy.root, 'views'))      
      @view_path    = path
      @template     = nil      
      trail.append_path('.')
      trail.append_extensions '.erb','.html', '.json', '.xml'      
    end
    
    def render
      unless template.nil?
        handler  = Tilt[template] || Tilt::ErubisTemplate
        tilt     = handler.new(template, nil, :outvar => '@_output_buffer')
        context  = Context.new(request)
        contents = unless layout.nil?
          wrapped  = Tilt.new(layout, nil, :outvar => '@_output_buffer')
          contents = wrapped.render(context) do |*args|
            tilt.render(context, *args)
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
  
    class Context
      include Tipsy::Helpers            
      
      attr_accessor :request, :content, :root
      
      def initialize(req)
        @request = req, @root = Tipsy.root
        super
      end
      
    end
    
  end
end

Tilt.prefer Tilt::ErubisTemplate, 'erb'