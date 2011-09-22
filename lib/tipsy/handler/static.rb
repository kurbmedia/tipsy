require 'rack'

module Tipsy
  module Handler
    ##
    # Handles serving/delivering static files from the 
    # /public directory.
    # 
    class StaticHandler    
      attr_reader :app, :try_files, :static

      def initialize(app, options)
        @app       = app
        @try_files = ['', *options.delete(:try)]      
        @static    = ::Rack::Static.new(lambda { [404, {}, []] }, options)
      end

      def call(env)
        pathinfo = env['PATH_INFO']
        
        if(File.basename(pathinfo) == "favicon.ico")
          resp = static.call(env.merge!({ 'PATH_INFO' => pathinfo }))
          unless 404 == resp[0]
            resp[1].merge!({ "Pragma" => "nocache", "Cache-Control" => "max-age=0" })
            return resp
          end
        end
        
        found    = nil
        try_files.each do |path|
          response = static.call(env.merge!({ 'PATH_INFO' => pathinfo + path }))
          break if 404 != response[0] && found = response
        end
        found or app.call(env.merge!('PATH_INFO' => pathinfo))
      end      
    end
    
  end
end