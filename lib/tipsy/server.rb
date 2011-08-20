require 'rack'
require 'hike'
require 'tipsy/handlers/all'

module Tipsy  
  class Server
    
    attr_reader :request
    attr_reader :response

    def initialize      
      @last_update = Time.now      
    end
    
    def call(env)      
      @request      = Request.new(env)
      @response     = Response.new
      path          = request.path_info.to_s.sub(/^\//, '')
      view          = Tipsy::View.new(path)
      view.request  = @request
      content       = view.render
      content.nil? ? not_found : finish(content)
    end
    
    private
    
    def finish(content)
      [ 200, { 'Content-Type' => 'text/html' }, [content] ]
    end
    
    def not_found
      [ 400, { 'Content-Type' => 'text/html' }, [] ]
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
    
    class ShowExceptions < Rack::ShowExceptions
      @@eats_errors = Object.new
      def @@eats_errors.flush(*) end
      def @@eats_errors.puts(*) end

      def initialize(app)
        @app      = app
        @template = ERB.new(template)
      end
      
      def template
        @@template ||= File.readlines(File.expand_path("./templates/", __FILE__) << "/exception.html").join("\n")
      end

      def call(env)
        begin
          @app.call(env)
        rescue Exception => e
          errors, env["rack.errors"] = env["rack.errors"], @@eats_errors
          if respond_to?(:prefers_plain_text?) and prefers_plain_text?(env)
            content_type = "text/plain"
            body = [dump_exception(e)]
          else
            content_type = "text/html"
            body = pretty(env, e)
          end
          env["rack.errors"] = errors
          
          [500, { "Content-Type" => content_type, "Content-Length" => Rack::Utils.bytesize(body.join).to_s }, [body]]
        end
      end
      
      def frame_class(frame)
        if frame.filename =~ /lib\/tipsy.*\.rb/
          "framework"
        elsif defined?(Gem) && frame.filename.include?(Gem.dir) || frame.filename =~ /\/bin\/(\w+)$/
          "system"
        else 
          "app"
        end
      end
      
    end
    
  end

end

