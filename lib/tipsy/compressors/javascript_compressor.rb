##
# Includes an interface to Google's Online Closure Compiler. 
# Uglifier is recommended (gem install uglifier) however to support environments where Node.js
# is unavailable this can be used as a fallback.
# 
require 'net/http'
require 'uri'

module Tipsy
  module Compressors
    
    module Closure
      def compress(js)
        return js unless Tipsy::Site.config.compile.compress_javascripts
        return js if js.to_s.blank?
        post_data = {
          'compilation_level' => 'SIMPLE_OPTIMIZATIONS',
          'js_code'           => js.to_s,
          'output_format'     => 'text'
        }
        request = Net::HTTP.post_form(URI.parse('http://closure-compiler.appspot.com/compile'), post_data)
        request.body.to_s
      end      
    end
    
    module Uglifier
      def compress(js)
        return js unless Tipsy::Site.config.compile.compress_javascripts
        ::Uglifier.compile(js, :max_line_length => 500, :squeeze => true, :copyright => false)
      end
    end
    
    class JavascriptCompressor      
      def initialize
        begin 
          require 'uglifier'
          self.class.send(:include, Uglifier)
        rescue LoadError
          Tipsy.logger.info("Add the Uglifier gem to your gemfile for better javascript support")
          self.class.send(:include, Closure)
        end
      end      
    end
    
  end
end