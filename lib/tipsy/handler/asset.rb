require 'sprockets'
require 'hike'
require 'tipsy/handler/sass'

module Tipsy
  module Handler
    ##
    # The AssetHandler is a subclass of Sprockets::Environment resposible for delivering
    # assets back to the browser. In development assets should be defined under: 
    # javascripts: /assets/javascripts
    # images:      /assets/images
    # stylesheets: /assets/stylesheets
    # 
    # Configure delivery urls using Tipsy::Site.asset_path, or Tipsy::Site.type_path where 'type' is the type of asset to configure
    # Although assets are stored in the /assets folder, when compiled these directories will be used for the final 
    # output. This way assets can be organized during development, but placed anywhere when deployed
    # 
    class AssetHandler < ::Sprockets::Environment
      attr_reader :asset_env
      
      class << self
        def map!
          fpaths = [:javascripts_path, :css_path, :images_path].collect do |p| 
            path = ::Pathname.new(Tipsy::Site.send(p))
            (path.absolute? ? path.to_s : path.to_s.sub(/^\//,''))
          end
          fpaths.inject({}) do |hash, path|
            hash.merge!("#{path}" => self.new)
          end
        end
      end
      
      def initialize
        ::Sprockets.register_engine '.scss', Tipsy::Handler::SassHandler
        super(Tipsy.root) do |env|
          @asset_env = env
        end
        append_path "assets/javascripts"
        append_path "assets/images"
        append_path "assets/stylesheets"
        
        configure_compass!
        self
        
      end
      
      ##
      # Setup compressors for compilation
      # 
      def prepare_compiler
        asset_env.css_compressor = Tipsy::Compressors::CssCompressor.new
        asset_env.js_compressor  = Tipsy::Compressors::JavascriptCompressor.new
      end
      
      ##
      # When exceptions are thrown through Sprockets, ensure that the 
      # current indexes are expired. This ensures we never receive a CircularDependency error.
      # 
      def javascript_exception_response(exception)      
        expire_index!
        super(exception)
      end

      def css_exception_response(exception)      
        expire_index!
        super(exception)
      end
      
      private
      
      def configure_compass!
        begin
          require 'compass'
          require 'sass/plugin'

          compass_config = ::Compass::Configuration::Data.new("project")
          compass_config.project_type     = :stand_alone
          compass_config.project_path     = Tipsy.root

          Tipsy::Site.compass.keys.each do |setting|
            compass_config.send("#{setting.to_s}=", Tipsy::Site.compass[setting])
          end

          Compass.add_project_configuration(compass_config)
          ::Sass::Plugin.engine_options.merge!(Compass.sass_engine_options)

        rescue LoadError
          require 'tipsy/helpers/sass'
        end
      end
      
    end  
      
  end
end