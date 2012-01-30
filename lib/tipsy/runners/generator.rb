module Tipsy
  module Runners
    class Generator      
      attr_reader :site_name, :site, :source_path, :dest_path
      
      include Tipsy::Utils::System
      
      def excludes
        @_excludes ||= ['.svn', '.git', '.gitignore', '.sass-cache', 'config.erb', '.DS_Store']
      end
      
      def initialize(args, site)
        @site_name, @site = args.first, site
        @source_path = File.expand_path("../../../templates/site", __FILE__)
        @dest_path   = File.join(Tipsy.root, site_name)
        ensure_destination
        copy_tree(source_path, dest_path)
        
        public_dir = File.join(Tipsy.root, site_name, "public")
        File.mkdir_p(public_dir) unless ::Dir.exists?(public_dir)
        
      end
      
      private
      
      def ensure_destination
        ::FileUtils.mkdir(dest_path) unless ::File.exists?(dest_path) && ::File.directory?(dest_path)
      end
      
    end
  end
end