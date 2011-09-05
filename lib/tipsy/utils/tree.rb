require 'find'
require 'pathname'

module Tipsy
  module Utils
    ##
    # Class for processing file trees. Copies a source tree to a destination tree
    # excluding specific files and directories.
    # 
    class Tree
      include Tipsy::Utils::System
      
      attr_reader :source_path, :dest_path, :folders, :files
      attr_accessor :excludes
      
      def initialize(src, dest, excl = nil)
        @source_path = normalize_path(::Pathname.new(src))
        @dest_path   = normalize_path(::Pathname.new(dest))
        @excludes = (excl || ['.svn', '.git', '.gitignore', '.sass-cache', 'config.erb', '.rb', '.DS_Store'])
      end
      
      def collect!
        @folders, @files = [], []
        ::Find.find(source_path.to_s).each do |path|
          next if path == source_path.to_s
          if excluded?(path) || excluded_path?(path)
            ::Find.prune if ::File.directory?(path)
            next
          end
          if ::File.directory?(path)
            @folders << normalize_path(::Pathname.new(path))
          else
            @files << normalize_path(::Pathname.new(path))
          end
        end
      end
      
      def copy!
        collect! if folders.nil? || files.nil?
        folders.each do |folder|
          mkdir_p(folder.to_s.gsub(source_path.to_s, dest_path.to_s))
        end
        files.each do |file|
          copy_file(file.to_s, file.to_s.gsub(source_path.to_s, dest_path.to_s))
        end
      end

      def excluded_path?(src)
        path = ::Pathname.new(src)
        rel  = path.relative_path_from(source_path).to_s
        excludes.detect{ |route| route == src || route == rel.to_s }
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
      
    end
  end
end
    