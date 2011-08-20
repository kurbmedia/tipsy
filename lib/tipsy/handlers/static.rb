require 'rack'

module Tipsy
  class StaticHandler
    
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
end