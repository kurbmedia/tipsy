require 'active_support/configurable'

module Tipsy
  
  class Site
    include ActiveSupport::Configurable
    config_accessor :asset_path, :compile_to, :css_path, :javascripts_path, :images_path, :fonts_path,
                    :public_path, :load_paths, :compile_to, :compile, :compass
    ##
    # Site configuration options
    # 
    # General:
    # port: The port in which the server should run
    # address: The address on which the server should run
    # public_path: Path to the public files/assets
    # 
    # Assets:
    # asset_path: The path in which assets should be preserved
    # assets.paths: Paths in which sprockets will look for assets    
    # assets.javascripts_path: Path in which javascript files should be served. Helper methods will use this path
    # assets.images_path: Path in which image assets should be served. Helper methods will use this path
    # assets.css_path: Path in which stylesheets should be served. Helper methods will use this path
    # 
    # Compiling:
    # compile_path: The directory in which the site will be compiled
    # compile.preserve: An array of files or directories that will be preserved when the compile folder is rebuilt.
    
    config.port       = 4000
    config.address    = '0.0.0.0'
    
    config.public_path       = File.join(Tipsy.root, 'public')
    config.load_paths        = ::ActiveSupport::OrderedOptions.new( 'assets' => [] )
    config.asset_path        = '/assets'
    config.images_path       = asset_path
    config.fonts_path        = "/fonts"
    config.javascripts_path  = asset_path
    config.view_path         = File.join(Tipsy.root, 'views')
    config.css_path          = asset_path
    config.compile_to        = File.join(Tipsy.root, 'compiled')
    
    config.compile           = ::ActiveSupport::OrderedOptions.new
    config.compile.assets    = ['screen.css', 'site.js']
    config.compile.preserve  = [".svn", ".gitignore", ".git"]
    config.compile.skip      = []

    config.compile.compress_css = true
    config.compile.compress_javascripts = true
    
    config.compile.enable_rewrite = true
    config.compile.rewrite_mode   = :htaccess

    config.compass                  = ::ActiveSupport::OrderedOptions.new
    config.compass.images_path      = File.join('assets', 'images')
    config.compass.sass_dir         = File.join('assets', 'stylesheets')
    config.compass.images_dir       = File.join('assets', 'images')
    config.compass.http_images_path = "/#{File.basename(config.images_path)}"
    config.compass.relative_assets  = false
    config.compass.line_comments    = false
    
    # enables php processing during development. 
    # at compile time, php code is left in-tact
    config.enable_php               = false 

    def self.configure!
      @_callbacks = { :before => [], :after => [] }
      local_config = File.join(Tipsy.root, 'config.rb')
      if File.exists?(local_config)
        bind = binding
        self.class_exec do
          File.open(local_config).each do |line|
            next if line.to_s[0] == "#" || line.to_s.strip.blank?
            eval("config."+ line.to_s, bind, local_config)
          end
        end
      end
    end
    
    ##
    # Callback support
    # 
    [:compile].each do |callback|
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def self.before_#{callback}(&block)
          if block_given?
            @_callbacks[:before] << block
          else
            @_callbacks[:before].each(&:call)
          end
        end

        def self.after_#{callback}(&block)
          if block_given?
            @_callbacks[:after] << block
          else
            @_callbacks[:after].each(&:call)
          end
        end
      METHOD
    end
    
    
    def initialize      
    end
          
  end
  
end