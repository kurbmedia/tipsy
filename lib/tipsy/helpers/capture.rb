module Tipsy
  module Helpers
    module Capture
  
      def content_for(name, content = nil, &block)
        content ||= capture(&block) if block_given?
        instance_variable_set("@_#{name}", content) if content
        instance_variable_get("@_#{name}") unless content
      end

      def capture(&block)
        buffer = ""
        orig_buffer, @_output_buffer = @_output_buffer, buffer
        yield
        buffer
        ensure
          @_output_buffer = orig_buffer
      end
      
    end      
  end
end