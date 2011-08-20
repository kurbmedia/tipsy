module Tipsy
  module Utils
    
    module Stdout
      def log_action(action, name)
        name = name.gsub(dest_path, '').sub(/^\//, '')
        Tipsy.logger.log_action(action, name)
      end
    end
    
    module System
      include Stdout
      
      def excluded_files
        @excludes ||= ['.git', '.gitignore', '.sass-cache', 'config.erb', '*.rb', '.', '..']
      end
      
      def excluded?(file)
        return true if excluded_files.include?(file)
        excluded_files.detect{ |exc| File.basename(exc).to_s.match(exc) }.nil?
      end
      
      ##
      # Copies from one location to another
      # 
      def make_file(source, destination)
        log_action("create", destination)
        FileUtils.cp(source, destination)
      end
      
      ##
      # Makes a matching folder in destination from source
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