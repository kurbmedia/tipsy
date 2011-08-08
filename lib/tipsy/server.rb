require 'rack'
require 'sprockets'
require 'hike'

module Tipsy
  
  class Server
    
    attr_reader :request
    attr_reader :response
    
    def self.init!
      Rack::Builder.new {
        use Rack::CommonLogger
        use Rack::ShowStatus
        use Rack::ShowExceptions
        use Tipsy::StaticFile, :root => Tipsy.options.public_path, :urls => %w[/]
        run Rack::Cascade.new([
        	Rack::URLMap.new({ "/#{File.basename(Tipsy.options.asset_path)}" => Tipsy::AssetHandler.new }),
        	Tipsy::Server.new        	
        ])
      }      
    end
      
    def initialize      
      @last_update = Time.now      
    end
    
    def call(env)      
      @request  = Request.new(env)
      @response = Response.new
      path      = request.path_info.to_s.sub(/^\//, '')
      view      = Tipsy::View.new(path, request)
      content   = view.render
      content.nil? ? not_found : finish(content)
    end
    
    private
    
    def finish(content)
      [ 200, { 'Content-Type' => 'text/html' }, [content] ]
    end
    
    def not_found
      [ 400, { 'Content-Type' => 'text/html' }, [] ]
    end
    
  end
  
  class AssetHandler < Sprockets::Environment    
    def initialize
      Sprockets.register_engine '.scss', Tipsy::Sass::Template
      
      Tipsy.sprockets = super(Tipsy.root) do |env|
        env.static_root    = Tipsy.options.asset_path
        #env.css_compressor = Tipsy::Compressors::CssCompressor.new
        # begin
        #   require 'uglifier'          
        #   env.js_compressor = Uglifier
        # rescue LoadError
        #   env.js_compressor = Tipsy::Compressors::JavascriptCompressor.new
        # end
      end      
      configure_paths!
      self
    end
    
    private
    
    def configure_paths!
      require 'sass/plugin'      
      append_path "assets/javascripts"
      append_path "assets/images"
      append_path "assets/stylesheets"
      Tipsy.options.assets.paths |= self.paths
    end
  end
  
  # From the rack/contrib TryStatic class
  class StaticFile
    attr_reader :app, :try_files, :static
    
    def initialize(app, options)
      @app       = app
      @try_files = ['', *options.delete(:try)]
      @static    = ::Rack::Static.new(lambda { [404, {}, []] }, options)
    end

    def call(env)
      orig_path = env['PATH_INFO']
      found = nil
      try_files.each do |path|
        resp = static.call(env.merge!({'PATH_INFO' => orig_path + path}))
        break if 404 != resp[0] && found = resp
      end
      found or app.call(env.merge!('PATH_INFO' => orig_path))
    end
  end
    
  
  class Request < Rack::Request    
    # Hash access to params
    def params
      @params ||= begin
        hash = HashWithIndifferentAccess.new.update(Rack::Utils.parse_nested_query(query_string))
        post_params = form_data? ? Rack::Utils.parse_nested_query(body.read) : {}
        hash.update(post_params) unless post_params.empty?
        hash
      end
    end    
  end

  class Response < Rack::Response
    def body=(value)
      value.respond_to?(:each) ? super(value) : super([value])
    end
  end
  
end

