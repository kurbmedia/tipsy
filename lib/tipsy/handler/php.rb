require 'tilt'

module Tipsy
  module Handler
    ##
    # The PHP engine allows processing/rendering of php templates within the server 
    # environment. To process php templates, use the template.html.php naming syntax.
    # 
    class PhpHandler < Tilt::Template
      
      self.default_mime_type = 'text/html'
      
      def prepare
        @engine = PhpProcessor.new(data)
      end

      def evaluate(scope, locals, &block)
        @output ||= @engine.render
      end
    end
    
    class PhpProcessor
      attr_accessor :data

      def initialize(d)
        @data = d
      end

      def render 
        file   = Tempfile.new("tipsy_php_#{Time.now.to_i}")
        result = ""
        begin
          file.write(@data)
          file.rewind
          result = `php #{file.path}`
        ensure
          file.close
          file.unlink
        end  
        result
      end
    end
    
  end
end

Tilt.register(Tipsy::Handler::PhpHandler, 'php')