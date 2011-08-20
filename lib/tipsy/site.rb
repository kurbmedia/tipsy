require 'ostruct'
require 'tipsy/handlers/all'
require 'tipsy/site/config'
require 'tipsy/site/utils'

module Tipsy
  class Site
    attr_reader :env, :root
    
    class << self
      def config
        @config ||= Config.new
      end
      
      def run(args, stdin)
        
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
        use Tipsy::StaticHandler, :root => Tipsy.options.public_path, :urls => %w[/]
        run Rack::Cascade.new([
        	Rack::URLMap.new(Tipsy::AssetHandler.to_url_map),
        	Tipsy::Server.new
        ])
      }
    end
    
  end
end