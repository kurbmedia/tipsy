require 'rack'
require 'tipsy/server'

module Tipsy
  class Application
    
    class_attribute :config, :instance_writer => false    
    attr_reader :app
        
    def self.create(name = nil)
      raise "Missing project name for 'tipsy new'" unless name
      Tipsy::Generator.create_project!(name)
    end
    
    def self.build
      Tipsy::Builder.new(self.config.build_path)
    end
    
    def self.initialize!
      self.config = Tipsy.options
      begin
        require File.join(Tipsy.root, 'config.rb')
      rescue LoadError
        puts "To configure additional settings, create a config.rb in your root path. (#{Tipsy.root})"
      end
    end
    
    def self.run
      initialize!
      self.new
    end
    
    def initialize
      
      @app = Rack::Builder.new {
        use Rack::CommonLogger
        use Rack::ShowStatus
        use Rack::ShowExceptions
        use Tipsy::StaticFile, :root => Tipsy.options.public_path, :urls => %w[/]
        run Rack::Cascade.new([
        	Rack::URLMap.new({ "/#{File.basename(Tipsy.options.asset_path)}" => Tipsy::AssetHandler.new }),
        	Tipsy::Server.new        	
        ])
      }
      
      puts "Tipsy #{Tipsy::VERSION} running on #{config.address}:#{config.port}"
      
      begin run_thin
      rescue LoadError
        begin run_mongrel
        rescue LoadError
          run_webrick
        end
      end      
    end
    
    private

    def server_opts
      { :Port => config.port, :Host => config.address }
    end
    
    def run_thin
      handler = Rack::Handler.get('thin')
      handler.run app, server_opts do |server|
        puts "Running Tipsy with Thin (#{Thin::VERSION::STRING})."
      end
      exit(0)
    end
    
    def run_mongrel
      handler = Rack::Handler.get('mongrel')
      handler.run app, server_opts do |server|
        puts "Running Tipsy with Mongrel (#{Mongrel::Const::MONGREL_VERSION})."
      end
      exit(0)
    end
    
    def run_webrick
      handler = Rack::Handler.get('webrick')
      handler.run app, server_opts do |server|
        puts "Running Tipsy with Webrick. To use Mongrel or Thin, add them to your Gemfile"
        trap("INT"){ server.shutdown }
      end
    end
    
  end
end