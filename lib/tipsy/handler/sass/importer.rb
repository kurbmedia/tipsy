begin
  require 'compass'
rescue LoadError
end

module Tipsy
  module Handler
    class SassHandler < ::Tilt::ScssTemplate
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

    end
  end
end