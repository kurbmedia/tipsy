module Tipsy
  module Logging
    
    def benchmark(message, &block)
      start = Time.now
      yield
      finish    = Time.now
      total_time = ((finish - start) * 1000.0)
      logger.info("#{message} (#{sprintf( "%0.02f", total_time)}ms)")
    end
    
    def log_action(name, action)
      logger.print logger.colorize(:green, (name.rjust(12, ' ') << " "), :clear, action)
    end
    
    def logger
      @__logger ||= Tipsy.logger
    end
    
  end
  
  class Logger
    COLORS = { :clear => 0, :red => 31, :green => 32, :yellow => 33 }    
    attr_reader :stdout
    
    def initialize(o)
      @stdout = o
      @cache  = []
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
    
    def info(msg)
      print msg
    end
    
    def warn(msg)
      print colorize(:yellow, "Warning: ", :clear, msg)
    end
    
    def error
      print colorize(:red, "Error: ", :clear, msg)
    end
    
  end
  
end