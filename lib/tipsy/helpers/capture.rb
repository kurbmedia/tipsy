module Tipsy
  module Helpers
    module Capture
  
      def content_for(name, content = nil, &block)
        content ||= capture(&block) if block_given?
        instance_variable_set("@_#{name}", content) if content
        instance_variable_get("@_#{name}").to_s unless content
      end
      
      def content_for?(name)
        !instance_variable_get("@_#{name}").nil?
      end

      def capture(*args)
        buffer ||= ""
        @output_buffer, old_buffer = buffer, @output_buffer
        yield
        @output_buffer
      ensure
        @output_buffer = old_buffer
      end
      
    end          
  end
end