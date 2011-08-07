module Tipsy
  module Builder
    class ExportBuilder < Base
      
      def initialize
        @source_path = Tipsy.root
        @dest_path   = Tipsy.options.build_path
      end
      
      def build!
        FileUtils.mkdir(dest_path) unless File.exists?(dest_path) && File.directory?(dest_path)
      end
      
    end
  end
end