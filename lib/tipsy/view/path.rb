require 'hike'

module Tipsy
  module View
    class Path < ::Hike::Trail
      
      def initialize
        super(Tipsy.root)
        append_path('.')
        append_extensions '.erb','.html', '.json', '.xml', '.php'
      end
      
      def locate_template(view_path)
        with_temporary_scope('views') do
          @_template ||= (find(view_path) || find(File.join(view_path, "index")))
        end
      end
      
      def locate_layout(name)
        with_temporary_scope('layouts') do
          @_layout ||= find(name)
        end
      end
      
      def locate_relative(path, name)
        with_temporary_scope("views", path) do
          find(name)
        end
      end
      
      private 
      
      def with_temporary_scope(*new_scope)
        old_paths = @paths
        new_scope = [Tipsy.root, new_scope].flatten
        append_path(File.join(*new_scope))
        yield
      ensure
        @paths = old_paths
      end
      
    end
  end
end