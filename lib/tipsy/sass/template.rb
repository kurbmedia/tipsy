require 'tilt'
require 'sass/engine'

module Tipsy
  module Sass
    class Template < Tilt::ScssTemplate
      self.default_mime_type = 'text/css'
      
      class Importer
        attr_reader :context

        def initialize(context)
          @context = context
        end

        def find_relative(name, base, options)
          pathname = resolve_sass_path(name, {:base_path => base}.merge(options))
          ::Sass::Engine.new(pathname.read, options.merge(:importer => self))
        end

        def find(name, options)
          pathname = resolve_sass_path(name, options)
          ::Sass::Engine.new(pathname.read, options.merge(:importer => self))
        end

        def mtime(name, options)
          if pathname = resolve_sass_path(name, options)
            pathname.mtime
          end
        end

        def key(name, options)
          ["Sprockets:" + File.dirname(File.expand_path(name)), File.basename(name)]
        end
        
        def resolve_sass_path(name, options = {})
          (context.resolve("./#{name}", options) || context.resolve("./_#{name}", options))
        end
        
      end
      
      def prepare        
      end
      
      def evaluate(scope, locals, &block)
        ::Sass::Engine.new(data, {
          :filename   => eval_file,
          :line       => line,
          :syntax     => :scss,
          :importer   => Importer.new(scope)
        }).render
      end
      
    end
  end
end