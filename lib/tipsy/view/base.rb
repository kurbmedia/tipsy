module Tipsy
  module View
    class Base
      
      attr_reader :lookup_context, :request, :response, :view_context
      
      def initialize(request, response)
        @request  = request
        @response = response
        @lookup_context = Tipsy::View::Path.new        
      end
      
      def render
        
        template      = lookup_context.locate_template(current_path)        
        @view_context = Tipsy::View::Context.new(request, lookup_context, File.dirname(template), lookup_context)
        
        handler  = Tilt[template]
        tilt     = handler.new(template, nil, :outvar => '@output_buffer')      
        result   = tilt.render(view_context)
        
        unless view_context.layout == false
          layout = lookup_context.locate_layout(view_context.layout) 
          raise Tipsy::View::LayoutMissing.new("Missing layout '#{view_context.layout}'") and return if layout.nil?
          wrapped = Tilt[layout].new(layout, nil, :outvar => '@output_buffer')          
          result  = wrapped.render(view_context) do |*args|
            result
          end
        end
        
        generate_response(result)
        
      end
      
      private
      
      def current_path
        @_current_path ||= request.path_info.to_s.sub(/^\//, '')
      end
      
      def generate_response(content)
        response.status = ( content.nil? ? 404 : 200)
        response.headers['content-type'] = "text/html"
        response.body = content
        response
      end
      
    end
  end
end