require 'find'
require 'pathname'
require 'fileutils'

module Tipsy
  module Utils
    module System
      extend ActiveSupport::Concern
      
      def excludes
        @_excludes ||= ['.svn', '.git', '.gitignore', '.sass-cache', 'config.erb', '.rb', '.DS_Store']
      end
      
      def excludes=(arr)
        @_excludes = arr
      end

      def excluded?(file, against = nil)
        against ||= excludes
        return true if file.to_s == '.' || file.to_s == '..' || against.include?(file)
        check = ::Pathname.new(file)
        return true if against.include?(check.basename.to_s)
        !against.detect do |exc| 
          (check.basename == exc || check.extname == exc)
        end.nil?
      end

      ##
      # Copies from one location to another
      # 
      def copy_file(source, destination)
        return true if skip_file?(source)
        log_action("copy", destination)
        ::FileUtils.cp(source, destination)
      end

      ##
      # Makes a matching folder in destination from source
      #
      def copy_folder(dirname)
        return true if skip_path?(dirname)
        log_action("copy", dirname)
        ::FileUtils.mkdir_p(dirname)
      end

      ##
      # Basic alias
      # 
      def mkdir_p(path)
        return true if ::File.exists?(path)
        log_action("create", path)
        ::FileUtils.mkdir_p(path)
      end
      
      def make_file(path, content)
        ::FileUtils.touch(path) unless ::File.exists?(path)
        ::File.open(path, 'w').puts(content)
      end
      
      def rm_rf(path)
        log_action('delete', path)
        ::FileUtils.rm_rf(path)
      end
      
      def unlink(file)
        log_action('delete', file)
        ::File.unlink(file)
      end
      
      def empty_dir?(path)
        ::Dir.entries(path).reject do |ent| 
          ent == "." || ent == ".." || ent == path
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
      
      # Override in specific runner as necessary
      # Allows more fine-grained control per directory.
      def skip_path?(dirname)
        false
      end
      
      # Override in specific runner as necessary. 
      # Allows more fine-grained control per file.
      def skip_file?(filename)
        false
      end
      
      ##
      # Collect the entire tree of files and folders and yield to a block
      def enumerate_tree(path, &block)
        ::Find.find(path) do |path|
          yield path
        end
      end
      
      def log_action(name, action)
        ::Tipsy.logger.action(name, action.to_s.gsub(Tipsy.root, ""))
      end
      
      def normalize_path(pname)
        pname = ::Pathname.new(pname) if pname.is_a?(String)
        return pname if pname.absolute?
        ::Pathname.new(::File.join(Tipsy.root, pname.to_s))
      end
      
    end
  end
end