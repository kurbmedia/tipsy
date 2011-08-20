require 'sprockets'
require 'hike'
require 'tipsy/handlers/sass'

module Tipsy

  class AssetHandler < Sprockets::Environment
    
    def self.to_url_map
      fpaths = [:javascripts_path, :css_path, :images_path].collect{ |p| File.basename(Tipsy::Site.config.assets.send(p)) }
      fpaths.inject({}) do |hash, path|
        hash.merge!("/#{path}" => self.new)
      end
    end
    
    def initialize
      Sprockets.register_engine '.scss', Tipsy::SassHandler
      super(Tipsy.root) do |env|
        env.static_root = File.join(Tipsy.root, 'public')
        env.logger = Tipsy.logger
      end

      append_path "assets/javascripts"
      append_path "assets/images"
      append_path "assets/stylesheets"
      
      Tipsy.options.assets.paths |= self.paths

      configure_compass!
      self
    end
    
    def javascript_exception_response(exception)      
      expire_index!
      super(exception)
    end

    def css_exception_response(exception)      
      expire_index!
      super(exception)
    end
    
    def prepare_compiler
      css_compressor = Tipsy::Compressors::Css.new
      js_compressor  = Tipsy::Compressors::Javascript.new
    end
    
    private
    
    def configure_compass!
      require 'compass'
      require 'sass/plugin'

      compass_config = ::Compass::Configuration::Data.new("project")
      compass_config.project_type     = :stand_alone
      compass_config.project_path     = Tipsy.root
      compass_config.images_dir       = File.join('assets', 'images')
      compass_config.sass_dir         = File.join('assets', 'stylesheets')
      compass_config.http_images_path = "/#{File.basename(Tipsy::Site.config.assets.images_path)}"
      compass_config.relative_assets  = false
      
      Compass.add_project_configuration(compass_config)
      ::Sass::Plugin.engine_options.merge!(Compass.sass_engine_options)
    end
    
  end
  
end