require 'optparse'
require 'tipsy/site'

module Tipsy
  class Runner
    attr_reader :args, :site
    
    def initialize(ar, stdin)
      @args = [ar].flatten    
      cmd = args.first || "serve"
      cmd = "serve"  if ['', 'run', 's', 'serve'].include?(cmd)
      cmd = "create" if cmd == 'new'
      args.shift
      Tipsy::Site.configure!
      @site = Tipsy::Site.new
      send(:"#{cmd}")
    end
    
    ##
    # Create an instance of Rack::Builder to serve the "static" site.
    # @usage From the command line,
    #  run `tipsy`, `tipsy serve` or simply `tipsy s`
    # 
    def serve
      require 'tipsy/server'
      require 'tipsy/view'
      require 'rack'
      
      app = Rack::Builder.new {
        use Rack::Reloader
        use Rack::ShowStatus
        use Rack::ShowExceptions
        use Tipsy::Handler::StaticHandler, :root => Tipsy::Site.config.public_path, :urls => %w[/]
        run Rack::Cascade.new([
        	Rack::URLMap.new(Tipsy::Handler::AssetHandler.map!),
        	Tipsy::Server.new
        ])
      }.to_app
      
      conf    = Tipsy::Site.config
      options = {
        :Host => conf.address,
        :Port => conf.port
      }
      
      Tipsy::Server.run!(app, options)
    end
    
    ##
    # Generates a new site in the specified path. 
    # @usage From the command line, run `tipsy new name_of_site_to_create`
    #
    def create
      Tipsy::Runners::Generator.new(args, @site)
    end
    
    ##
    # Responsible for compiling the final site for deployment. This process will 
    # take the following steps:
    # 
    # 1. Copy files recursively from /public
    # 2. Compile javascripts, sprites, and css files into their respective directories within the compile folder
    # 3. Render all templates and place in their proper directories within the compile folder.
    # 
    # @usage From the command line, run `tipsy compile`
    # 
    def compile
      Tipsy::Runners::Compiler.new
    end
    
    
    ##
    # Responsible for deploying a compiled site to a production server. 
    # @usage From the command line, run `tipsy deploy`
    # 
    def deploy
      Tipsy::Runners::Deployer.new
    end
    
  end
  
end