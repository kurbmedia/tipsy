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

      Rack::Builder.new {
        use Rack::CommonLogger
        use Rack::ShowStatus
        use Tipsy::Server::ShowExceptions
        use Tipsy::StaticHandler, :root => Site.config.public_path, :urls => %w[/]
        run Rack::Cascade.new([
        	Rack::URLMap.new(Tipsy::AssetHandler.to_url_map),
        	Tipsy::Server.new
        ])
      }
    end
    
  end
end

require 'tipsy/site/config'