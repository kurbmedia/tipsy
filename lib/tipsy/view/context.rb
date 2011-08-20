module Tipsy
  module View
    module Context
        
      private
        
      def _prepare_context
        @_output_buffer = nil, @_captures = {}
        module_names = []
        includes = Dir.glob(File.expand_path(Tipsy.root) << "/helpers/*.rb").inject([]) do |arr, helper|
          module_names << File.basename(helper, '.rb').classify
          arr.concat File.open(helper).readlines          
        end
        module_names.each{ |mod| includes.concat(["\n include #{mod}"]) }
        view_context.send(:include, Tipsy::Helpers)
        view_context.class_eval(includes.join("\n"))
      end
      
    end
 
  end
end