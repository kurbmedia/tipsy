require 'tilt'
require 'sass/engine'
require 'compass'

module Tipsy
  module Sass
    class Template < Tilt::ScssTemplate
      self.default_mime_type = 'text/css'
      
      class Resolver
        attr_accessor :context        
        def initialize(context)
          @context = context
        end
        def resolve(path, content_type = :self)
          options = {}
          options[:content_type] = content_type unless content_type.nil?
          context.resolve(path, options)
        rescue Sprockets::FileNotFound, Sprockets::ContentTypeMismatch
          nil
        end
        def public_path(path, scope)
          context.asset_paths.compute_public_path(path, scope)
        end
        def process(path)
          context.environment[path].to_s
        end
      end
      
      
      class Importer
        
        GLOB = /\*|\[.+\]/
        PARTIAL = /^_/
        HAS_EXTENSION = /\.css(.s[ac]ss)?$/
        SASS_EXTENSIONS = {
              ".css.sass" => :sass,
              ".css.scss" => :scss,
              ".sass" => :sass,
              ".scss" => :scss
        }            
        
        attr_reader :context

        def initialize(context)
          @context = context
          @resolver = Resolver.new(context)
        end
        
        def sass_file?(filename)
          filename = filename.to_s
          SASS_EXTENSIONS.keys.any?{|ext| filename[ext]}
        end

        def syntax(filename)
          filename = filename.to_s
          SASS_EXTENSIONS.each {|ext, syntax| return syntax if filename[(ext.size+2)..-1][ext]}
          nil
        end
        
        def render_with_engine(data, pathname, options = {})
          ::Sass::Engine.new(data, options.merge(:filename => pathname.to_s, :importer => self, :syntax => syntax(pathname)))
        end

        def resolve(name, base_pathname = nil)
          name = Pathname.new(name)
          if base_pathname && base_pathname.to_s.size > 0
            root = Pathname.new(context.root_path)
            name = base_pathname.relative_path_from(root).join(name)
          end
          partial_name = name.dirname.join("_#{name.basename}")
          @resolver.resolve(name) || @resolver.resolve(partial_name)
        end
        
        def find_relative(name, base, options)
          base_pathname = Pathname.new(base)
          if pathname = resolve(name, base_pathname.dirname)
            context.depend_on(pathname)
            if sass_file?(pathname)
              render_with_engine(pathname.read, pathname)
            else
              render_with_engine(@resolver.process(pathname), pathname)
            end
          else
            nil
          end
        end
        
        def find(name, options)
          if pathname = resolve(name)
            context.depend_on(pathname)
            if sass_file?(pathname)
              render_with_engine(pathname.read, pathname)
            else
              render_with_engine(@resolver.process(pathname), pathname)
            end
          else
            nil
          end
        end

        def mtime(name, options)
          if pathname = resolve_sass_path(name, options)
            pathname.mtime
          end
        end

        def key(name, options)
          ["Sprockets:" + File.dirname(File.expand_path(name)), File.basename(name)]
        end
        
        def resolve_sass_path(name, options = {}, relative = false)
          prefix = ( relative === false ? "" : "./" )
          (context.resolve("#{prefix}#{name}", options) || context.resolve("#{prefix}_#{name}", options))
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
        }.reverse_merge!(::Compass.sass_engine_options)).render
      end
      
    end
  end
end