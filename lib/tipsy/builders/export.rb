module Tipsy
  module Builder
    class ExportBuilder < Base
      attr_reader :view_path
      
      def initialize
        @source_path = Tipsy.root
        @dest_path   = Tipsy.options.build_path
        @view_path   = File.join(Tipsy.root, 'views')
      end
      
      def build!
        FileUtils.mkdir(dest_path) unless File.exists?(dest_path) && File.directory?(dest_path)
        process_location(source_path, dest_path)
      end
      
      protected
      
      def make_file(source, destination)
        filename = File.basename(source, '.html*')
        view     = Tipsy::View.new(Pathname.new(source).dirname)
      end
      
      def make_folder
        
      end
      
      class Request < Struct.new(:path, :params); end
      
    end
  end
end