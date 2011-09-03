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