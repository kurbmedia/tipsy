module Tipsy
  module Utils
    class Logger      
      COLORS = { :clear => 0, :red => 31, :green => 32, :yellow => 33 }    
      attr_reader :stdout

      def initialize(o)
        @stdout = o
      end
      
      def print(msg)
        puts msg
      end
      
      def action(name, action)
        print colorize(:green, (name.rjust(12, ' ') << " "), :clear, action)
      end

      def info(msg)
        print msg unless Tipsy.env.eql?("test")
      end

      def warn(msg)
        print colorize(:yellow, "Warning: ", :clear, msg)
      end

      def error
        print colorize(:red, "Error: ", :clear, msg)
      end
      
      private
      
      def colorize(*args)
        output = args.inject([]) do |arr, option|
          unless option.is_a?(Symbol) && COLORS[option]
            arr << option
          else
            arr << "\e[#{COLORS[option]}m"
          end
          arr
        end
        output.push("\e[0m").join("")
      end

    end
  end
end