require 'find'
require 'pathname'
require 'fileutils'

module Tipsy
  module Utils
    ##
    # Overrides file and directory methods for the test environment
    module SystemTest
      attr_reader :deletions, :creations
      
      extend ActiveSupport::Concern
      include System
      
      ##
      # Copies from one location to another
      # 
      def copy_file(source, destination)
        return true if skip_file?(source)
        set_created(destination)
      end

      ##
      # Makes a matching folder in destination from source
      #
      def copy_folder(dirname)
        return true if skip_path?(dirname)
        log_action("create", dirname)
        set_created(dirname)
      end

      ##
      # Basic alias
      # 
      def mkdir_p(path)
        return true if ::File.exists?(path)
        log_action("create", path)
        set_created(path)
      end
      
      def make_file(path, content)
        set_created(path)
      end
      
      def rm_rf(path)
        log_action('delete', path)
        set_deleted(path)
      end
      
      def unlink(file)
        log_action('delete', file)
        set_deleted(file)
      end
      
      def empty_dir?(path)
        ::Dir.entries(path).reject do |ent| 
          ent == "." || ent == ".." || ent == path || was_deleted?(File.join(path, ent))
        end.empty?
      end

      ##
      # Iterate through a file tree and process each file and folder.
      # 
      def copy_tree(src, dest)
        ::Dir.foreach(src) do |file|
          next if excluded?(file)
          source       = ::File.join(src, file)
          destination  = ::File.join(dest, file)

          if ::File.directory?(source)
            copy_folder(destination)
            copy_tree(source, destination)
          else
            copy_file(source, destination)
          end
        end
      end
     
      
      def log_action(name, action)
      end
      
      def was_deleted?(path)
        (@deletions ||= []).include?(path)
      end
      
      def was_created?(path)
        (@creations ||= []).include?(path)
      end
      
      private
      
      def set_created(path)
        (@creations ||= []) << path.to_s
      end
      
      def set_deleted(path)
        (@deletions ||= []) << path.to_s
      end
      
    end
  end
end