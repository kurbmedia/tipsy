module Tipsy
  module Builder
    class Base      
      attr_reader :source_path, :dest_path
      
      def excludes
        @excludes ||= ['.git', '.gitignore', '.sass-cache', 'config.erb', '*.rb', '.', '..']
      end
      
      def build!
        process_location(source_path, dest_path)
      end
      
      protected
      
      def excluded?(file)
        return true if excludes.include?(file)
        excludes.detect{ |exc| File.basename(exc).to_s.match(exc) }.nil?
      end
      
      def log_action(action, name)
        name = name.gsub(dest_path, '').sub(/^\//, '')
        Tipsy.logger.log_action(action, name)
      end
      
      ##
      # By default make_file copies from one location to another
      # Overridden in non-local scenarios
      # 
      def make_file(source, destination)
        log_action("create", destination)
        FileUtils.cp(source, destination)
      end
      
      ##
      # By default make_folder makes a matching folder in destination from source
      # Overridden in non-local scenarios
      #
      def make_folder(dirname)
        log_action("create", dirname)
        FileUtils.mkdir(dirname)
      end
      
      ##
      # Iterate through a file tree and process each file and folder.
      # 
      def process_location(src, dest)
        Dir.foreach(src) do |file|
          next if excluded?(file)
          source       = File.join(src, file)
          destination  = File.join(dest, file)
          
          if File.directory?(source)
            make_folder(destination)
            process_location(source, destination)
          else
            make_file(source, destination)
          end
        end
      end
      
    end
  end
end