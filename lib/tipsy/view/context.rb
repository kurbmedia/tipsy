module Tipsy
  module View
    ##
    # All views are rendered within a context object. This object handles
    # transitioning data between templates and layouts.
    # 
    class Context      
      attr_reader :request, :template, :layout, :virtual_path, :lookup_context
      
      def initialize(request, template, path, lookup)
        @request        = request
        @layout         = 'default'
        @template       = template
        @virtual_path   = path
        @lookup_context = lookup
        @output_buffer  = nil
        self.class_eval do
          include Tipsy::Helpers
        end
      end
      
      def layout(set = nil)
        @layout = set unless set.nil?
        @layout
      end

    end
    
  end
end