require 'hike'

module Tipsy
  module View
    module Lookup
      
      private
      
      def find_layout
        @_layout ||= (view_lookup.find(File.join(view_path, '_layout')) || view_lookup.find('_layout'))
      end
      
      def view_lookup
        @_view_lookup ||= Hike::Trail.new(File.join(Tipsy.root, 'views'))
      end
      
      def lookup_template(expand = true)
        found = view_lookup.find(view_path)
        (expand == true ? (found || view_lookup.find(File.join(view_path, "index"))) : found)
      end
      
    end
  end
end