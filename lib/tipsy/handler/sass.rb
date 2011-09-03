require 'tilt'
require 'sass/engine'
require 'tipsy/handler/sass/resolver'
require 'tipsy/handler/sass/importer'

module Tipsy
  module Handler
    class SassHandler < ::Tilt::ScssTemplate
      self.default_mime_type = 'text/css'
      
      def prepare; end;

      def evaluate(scope, locals, &block)
        ::Sass::Engine.new(data, sass_engine_options(scope)).render
      end
      
      private
      
      def sass_engine_options(scope)
        options = {
          :filename   => eval_file,
          :line       => line,
          :syntax     => :scss,
          :importer   => Importer.new(scope)
        }
        begin
          require 'compass'
          options.reverse_merge!(::Compass.sass_engine_options)
        rescue LoadError
        end
        ensure options
      end
      
    end
  end
end