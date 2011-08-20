require 'tilt'
require 'tipsy/helpers'
require 'tipsy/view/renderers'
require 'tipsy/view/lookup'
require 'tipsy/view/context'

module Tipsy
  module View
    
    class Base
      include Renderers
      include Lookup
      include Context
      
      attr_reader :_output_buffer, :_captures
      
      def initialize(path)
        @_captures = {}
        @_output_buffer = nil
        _prepare_context
        self
      end
      
      private
      
      # Create an anonymous class for rendering.        
      def view_context
        @_view_context ||= Class.new(self)
      end              
      
      def render_to_body(file, locals)
        context = prepare
      end

    end
    
  end
end