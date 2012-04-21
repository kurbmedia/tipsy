require 'find'
require 'tipsy/view'

module Tipsy
  module Runners
    class Compiler
      include Tipsy::Utils::System
      
      attr_reader :source_path, :dest_path, :scope, :site
      
      def initialize(args, site)
        
        ENV['TIPSY_ENV'] = "compile"
        
        @site        = site
        @source_path = normalize_path(config.public_path)
        @dest_path   = normalize_path(config.compile_to)
        excluded     = [excludes, config.compile.preserve].flatten.uniq
        @_excludes   = excluded
        clean_existing!
        [:public, :images, :assets, :templates].each do |m|
          send(:"compile_#{m}!")
        end
        
        cleanup!
        
      end
      
      def config
        Tipsy::Site.config
      end
      
      def skip_path?(src)
        return false unless scope == :clean || scope == :public
      end

      def skip_file?(src)
        return false unless scope == :clean || scope == :public
        if scope == :public
          checks   = config.compile.skip
          relative = ::Pathname.new(src).relative_path_from(::Pathname.new(source_path))
          reldir   = relative.dirname.to_s
          return checks.detect{ |path| path == src || path == relative.to_s || reldir.to_s == path }
        end
        config.compile.preserve.detect do |path| 
          relative = src.to_s.gsub(Tipsy::Site.public_path, '').sub(/^\//, '')
          File.basename(src) == path || relative == path
        end
      end
      
      alias :skip_path? :skip_file?
      
      private
      
      def clean_existing!
        @scope = :clean
        return true unless ::File.directory?(dest_path)
        tree = Tipsy::Utils::Tree.new(dest_path, source_path)
        tree.collect!
        tree.files.each do |file|
          unlink(file)
        end
        
        tree.folders.map(&:to_s).sort{ |d1,d2| d2.size<=>d1.size }.each do |dir|
          rm_rf(dir) if empty_dir?(dir)
        end
      end
      
      def compile_public!
        @scope = :public
        log_action("copy", "public files")
        tree = Tipsy::Utils::Tree.new(source_path, dest_path)
        tree.excludes |= config.compile.skip
        tree.copy!
      end
      
      def compile_images!
        @scope = :images
        log_action("compile", "images")      
        image_path = File.join(dest_path, config.images_path)
        mkdir_p image_path
        copy_tree(File.join(Tipsy.root, 'assets', 'images'), image_path)
      end
      
      def compile_assets!
        @scope = :assets
        log_action('compile', 'assets')
        handler = Tipsy::Handler::AssetHandler.new
        handler.prepare_compiler

        config.compile.assets.each do |file|
          handler.each_logical_path do |path|
            should_compile = path.is_a?(Regexp) ? file.match(path) : File.fnmatch(file.to_s, path)
            next unless should_compile

            if asset = handler.find_asset(path)
              log_action("compile", asset.logical_path)            
              writepath = build_asset_path(asset, file)
              asset.write_to(writepath)
            end
            
          end
        end
      end
      
      def compile_templates!
        dirs = ::Dir[::File.join(Tipsy.root, "views") << "/**/**"].reject do |dir|
          dir == '.' || dir == ".." || dir[0] == "." || !::File.directory?(dir)
        end
        dirs = dirs.reject do |dir|
          
          # Skip folders that only have partials or all files/dirs excluded
          ::Dir.entries(dir).reject{ |f| f.to_s[0] == "_" || excluded?(f) }.empty?
        end.push(File.join(Tipsy.root, "views"))

        view_path  = ::File.join(Tipsy.root, "views")

        dirs.each do |path|          
          templates_in_path(path).each do |tpl|
            next if ::File.directory?(File.join(path, tpl)) || ::File.basename(tpl).to_s[0] == "_"
            
            route    = ::Pathname.new(path.gsub("#{Tipsy.root}/views", ""))
            route    = "/" if route.blank?
            route    = "/#{route.to_s}" unless route.absolute?
            route    = File.join(route.to_s, tpl.split(".").first) unless tpl.to_s.match(/^index/i)
            request  = MockRequest.new(route.to_s)
            view     = ::Tipsy::View::Base.new(request, MockResponse.new)            

            compiled = view.render
            next if view.template.nil?
            proper_name = proper_template_name(view.template)
            tpl_path    = ::Pathname.new(view.template)
            relation    = tpl_path.dirname.relative_path_from(::Pathname.new(view_path))
            
            if ::File.directory?(File.join(view_path, request.path))
              write_to = ::File.join(request.path, proper_name)                            
            else
              write_to = "#{request.path}#{::File.extname(proper_template_name(view.template))}"
            end
            
            mkdir_p(::File.join(dest_path, relation.to_s)) unless relation.to_s == "." || relation.to_s == ".."
            log_action("render", request.path)
            make_file(::File.join(config.compile_to, write_to), compiled.body)
          end
        end
      end
      
      def cleanup!
        wipe = { :files => [".DS_Store"], :dirs => [".sass-cache"] }
        enumerate_tree(dest_path) do |path|
          wipe[:files].each do|file| 
            ::File.unlink(path) if ::File.basename(path) == file
          end
          wipe[:dirs].each do |dir|
            ::FileUtils.rm_rf(path) if ::File.basename(path) == dir
          end
        end
      end
      
      class MockRequest
        attr_reader :path_info, :path
        def initialize(p)
          @path_info, @path = p, p
        end
      end
      
      class MockResponse
        attr_accessor :status, :body, :headers
        def initialize
          @headers = {}
        end
      end
      
      private
      
      def templates_in_path(path)
        ::Dir.entries(path).reject{ |file| file[0] == "_" || ::File.directory?(file) }
      end
      
      def proper_template_name(tpl)
        ::File.basename(tpl).gsub(/(md|haml|erb|rb|slim)/i, "").gsub(/\.$/, '')        
      end
      
      def build_asset_path(asset, file)
        base =  (file.to_s.match(/\.js$/i) ? :javascripts_path : (file.to_s.match(/\.css$/i) ? :css_path : :images_path))
        base = config.send(base)
        path = File.expand_path(File.join(config.compile_to, base))
        mkdir_p(path) unless File.directory?(path)
        File.join(path, asset.logical_path)
      end
      
    end
  end
end