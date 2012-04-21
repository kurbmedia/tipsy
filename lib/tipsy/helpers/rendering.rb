module Tipsy
  module Helpers
    module Rendering
      include Tipsy::Helpers::Capture
      
      def public_path
        Tipsy::Site.config.public_path
      end
      
      def render(options = {})
        options.symbolize_keys!
        assert_valid_keys!(options, :ssi, :template, :partial, :collection, :locals)
        
        if template = options.delete(:template)
          render_inline_template(template, options)
        elsif template = options.delete(:partial)
          render_inline_template(template, options, true)
        elsif template = options.delete(:ssi)
          if Tipsy.compiling?
            ssi_path = Pathname.new(template).absolute? ? template : "/#{template}"
            return "<!--#include virtual=\"#{ssi_path}\" -->"
          end
          render_inline_template(template, options)
        else
          raise 'Render requires a :ssi, :template, or :partial option.'
        end
      end
      
      private
      
      def render_inline_template(path, options = {}, partial = false) 
        
        to_render   = File.basename(path)
        to_render   = "_#{to_render}" if partial
        render_path = Pathname.new(path)
        render_path = render_path.absolute? ? render_path : lookup_context.locate_relative(render_path.dirname, to_render)
                
        unless render_path.nil?
          local_vars = options.delete(:locals) || {}
          results    = Tilt[render_path].new(render_path, nil, :outvar => "_inline_template")
          return capture{ results.render(self, local_vars).to_s }
        end
        
        raise "Missing #{ partial ? 'partial' : 'template' } #{to_render}."
        
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