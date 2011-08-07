require 'logger'

module Tipsy
  class Logger
    
    COLOR_VALUES = {
      :clear  => 0,
      :red    => 31,
      :green  => 32,
      :yellow => 33
    }
    
    attr_accessor :cache
    attr_reader :stdout
    
    def initialize(o)
      @stdout = o
      @cache  = []
    end
    
    def append(msg)
      @cache << msg
    end
    
    def flush!
      cache.each{ |c| print c }
    end
    
    def log_action(name, action)
      print colorize(:green, (name.rjust(12, ' ') << " "), :clear, action)
    end
    
    def info(msg)
      print msg
    end
    
    def warn(msg)
      print colorize(:yellow, "Warning: ", :clear, msg)
    end
    
    def error
      print colorize(:red, "Error: ", :clear, msg)
    end
    
    def colorize(*args)
      output = args.inject([]) do |arr, option|
        unless option.is_a?(Symbol) && COLOR_VALUES[option]
          arr << option
        else
          arr << "\e[#{COLOR_VALUES[option]}m"
        end
        arr
      end
      output.push("\e[0m").join("")
    end
    
    def print(msg)
      puts msg
    end
   
  end
end