require 'rack'
require 'hike'

module Tipsy  
  ##
  # Rack server implementation.
  # Tipsy::Server will run any Rack::Builder compatable format. If thin or mongrel
  # are availble, they will be used first, and in that order, with a fallback to webrick.
  # 
  class Server
    attr_reader :request, :response
    
    class << self    
      ##
      # Run the Rack::Builder application
      # @param [run] Rack::Builder An instance of Rack::Builder
      # 
      def run!(app, options)
        begin
          handler = Rack::Handler.get('thin')
          handler.run app, options do |server|
            puts "Running Tipsy with Thin (#{Thin::VERSION::STRING})."
          end
          exit(0)
        rescue LoadError
          begin
            handler = Rack::Handler.get('mongrel')
            handler.run app, options do |server|
              puts "Running Tipsy with Mongrel (#{Mongrel::Const::MONGREL_VERSION})."
            end
            exit(0)
          rescue LoadError
            handler = Rack::Handler.get('webrick')
            handler.run app, options do |server|
              puts "Running Tipsy with Webrick. To use Mongrel or Thin (recommended), add them to your Gemfile"
              trap("INT"){ server.shutdown }
            end
          end
        end
      end
    end
    
    def initialize      
      @last_update = Time.now      
    end
    
    def call(env)      
      @request  = Request.new(env)
      @response = Response.new      
      result    = Tipsy::View::Base.new(@request, @response)
      result.render.to_a
    end

    ##
    # Subclass Rack::Request to create a rails-like params hash.
    class Request < Rack::Request
      def params
        @params ||= begin
          hash = HashWithIndifferentAccess.new.update(Rack::Utils.parse_nested_query(query_string))
          post_params = form_data? ? Rack::Utils.parse_nested_query(body.read) : {}
          hash.update(post_params) unless post_params.empty?
          hash
        end
      end    
    end
    
    ##
    # Ensure proper body output
    class Response < Rack::Response
      def body=(value)
        value.respond_to?(:each) ? super(value) : super([value])
      end
    end
  end
  
end