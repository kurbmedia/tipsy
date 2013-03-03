require 'tilt'
require 'digest/md5'

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
        @engine.template = scope.template.full_path
        @output ||= @engine.render
      end
    end
    
    class PhpProcessor
      attr_accessor :data, :template, :env

      def initialize(d)
        @data  = d
        @cname = nil
        unless Dir.exists?(compile_to)
          FileUtils.mkdir(compile_to)
        end
      end
      
      def compile_to
        File.join(Tipsy.root, '.php-temp')
      end
      
      def cache_name
        @cname ||= ::Digest::MD5.hexdigest(template.gsub(File.join(Tipsy.root, 'views'), ''))
      end
      
      def tempfile
        File.join(compile_to, "#{cache_name}.php")
      end

      def render
        # if File.exists?(tempfile) && (File.mtime(tempfile) > File.mtime(template))
        #   return File.read(tempfile)
        # end
        puts "PARSE TEMPLATE #{template}"
        File.open(tempfile, 'w') do |file|
          file.puts(@data)
        end
        ``
        res = `php #{tempfile}`
        puts res.to_s
        res.to_s
      end
      
    end
  end
end

Tilt.register(Tipsy::Handler::PhpHandler, 'php')