require 'tilt'

module Tipsy
  module Renderers
   
    protected
    
    def render(file_or_collection, options = {})
      options, file_or_collection = file_or_collection, nil if file_or_collection.is_a?(Hash)
      options.symbolize_keys!
      
      file_or_collection ||= options.delete(:collection)      

      if file_or_collection || file_or_collection.is_a?(Array)
        _render_collection(file_or_collection, options)
      elsif tpl = options.delete(:template)
        _render_template(tpl, options)
      elsif tpl = options.delete(:partial)
        _render_template(tpl, options, true)
      else
        raise 'Render requires a :template or :partial option.'
      end
    end
    
    private
    
    def _render_template(name, options = {}, partial = false)
      to_render = ( partial === true ? "_#{name}" : name )
      to_render = view_lookup.find(to_render)
      unless to_render.nil?
        local_vars = options.delete(:locals) || {}
        return Tilt[to_render].new(to_render, nil).render(view_context, local_vars)
      end
      raise "Missing #{ partial ? 'partial' : 'template' } #{name}."
    end
    
    def _render_to_body(template, layout)
      unless template.nil?
        handler  = Tilt[template]
        tilt     = handler.new(template, nil, :outvar => '@_output_buffer')
                
        unless layout.nil?
          renderer  = Tilt.new(layout, nil, :outvar => '@_output_buffer')          
          contents = renderer.render(view_context) do |*args|
            tilt.render(view_context)
          end
        else
          tilt.render(context)
        end
        return contents
      end      
      nil
    end
    
    def _render_collection(collection, options = {})
      return nil if [collection].flatten.compact.empty?
      local_name = options.delete(:as) || collection.first.class.name.underscore
      view_name  = local_name
      collection.each do |item|
        @_output_buffer << render(:partial => view_name, :locals => { local_name => item })
      end
    end
    
  end
end