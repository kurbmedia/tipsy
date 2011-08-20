module Tipsy
  module Helpers
    module Capture
  
      def content_for(name, content = nil, &block)
        content ||= capture(&block) if block_given?
        instance_variable_set("@_#{name}", content) if content
        instance_variable_get("@_#{name}") unless content
      end
      
      def content_for?(name)
        !instance_variable_get("@_#{name}").nil?
      end

      def capture(&block)
        buffer = ""
        orig_buffer, @_output_buffer = @_output_buffer, buffer
        yield
        buffer
        ensure
          @_output_buffer = orig_buffer
      end
      
      def render(options = {})
        options.symbolize_keys!
        assert_valid_keys!(options, :template, :partial, :collection, :locals)
        
        if template = options.delete(:template)
          _render_template(template, options)
        elsif template = options.delete(:partial)
          _render_template(template, options, true)
        else
          raise 'Render requires a :template or :partial option.'
        end
      end
      
      private
      
      def _render_template(name, options = {}, partial = false)
        to_render = ( partial === true ? "_#{name}" : name )
        to_render = view_trail.find(to_render)
        unless to_render.nil?
          local_vars = options.delete(:locals) || {}
          results = Tilt[to_render].new(to_render, nil)
          return results.render(self, local_vars)
        end
        raise "Missing #{ partial ? 'partial' : 'template' } #{name}."
      end
      
      def assert_valid_keys!(hash, *keys)
        left = hash.keys.reject{ |k| keys.include?(k) }
        unless left.empty?
          raise 'Invalid keys for hash: #{left.join(", ")}'
        end
      end
      
    end      
  end
end