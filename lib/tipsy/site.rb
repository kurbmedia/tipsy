require 'active_support/ordered_options'
require 'ostruct'
require 'tipsy/site/utils'

module Tipsy
  class Site
    attr_reader :env, :root
    
    class << self
      def config
        @config ||= ::ActiveSupport::OrderedOptions.new
      end
      
      def configure(&block)
        yield config if block_given?
      end
      
      def run(args, stdin)
        args   = [args].flatten    
        to_run = args.first
        to_run = 'serve'  if [nil, 'run', 's'].include?(to_run)
        to_run = 'create' if to_run == 'new'
        args.shift        
        self.new.send(:"#{to_run}!")
      end
      
    end
    
    def initialize(root = nil, env = nil)
      @root ||= Tipsy.root
      @env  ||= Tipsy.env
      require 'tipsy/site/config'
    end
    
    def config
      self.class.config
    end
    
    def create!
      require 'tipsy/site/creator'
      SiteCreator.new(self)
    end
    
    def compile!
      require 'tipsy/site/compiler'
      SiteCompiler.new(self)
    end
    
    def serve!
      require 'tipsy/server'
      require 'rack'

      app = Rack::Builder.new {
        use Rack::Reloader
        use Rack::ShowStatus
        use Tipsy::Server::ShowExceptions
        use Tipsy::StaticHandler, :root => Tipsy::Site.config.public_path, :urls => %w[/]
        run Rack::Cascade.new([
        	Rack::URLMap.new(Tipsy::AssetHandler.to_url_map),
        	Tipsy::Server.new
        ])
      }.to_app
      
      Runner.new(app).run      
      
    end
    
    class Runner
      attr_reader :app
      
      def initialize(a); @app = a; end
      def options
        server_options = { :Port => Site.config.port, :Host => Site.config.address }
      end
      def run
        Tipsy.logger.info("Tipsy #{Tipsy::VERSION} running on #{Site.config.address}:#{Site.config.port}")
        begin run_thin
        rescue LoadError
          begin run_mongrel
          rescue LoadError
            run_webrick
          end
        end
      end
      def run_thin
        handler = Rack::Handler.get('thin')
        handler.run app, options do |server|
          puts "Running Tipsy with Thin (#{Thin::VERSION::STRING})."
        end
        exit(0)
      end

      def run_mongrel
        handler = Rack::Handler.get('mongrel')
        handler.run app, options do |server|
          puts "Running Tipsy with Mongrel (#{Mongrel::Const::MONGREL_VERSION})."
        end
        exit(0)
      end

      def run_webrick
        handler = Rack::Handler.get('webrick')
        handler.run app, server_opts do |server|
          puts "Running Tipsy with Webrick. To use Mongrel or Thin (recommended), add them to your Gemfile"
          trap("INT"){ server.shutdown }
        end
      end
    end
  end
end