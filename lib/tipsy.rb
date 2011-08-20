require "tipsy/version"
require "active_support/all"
require 'optparse'
require 'tipsy/configuration'

module Tipsy

  autoload :Application,  'tipsy/application'
  autoload :Server,       'tipsy/server'
  autoload :Responder,    'tipsy/handler'
  autoload :Helpers,      'tipsy/helpers'  
  autoload :Builder,      'tipsy/builder'
  autoload :Logger,       'tipsy/logger'
  
  module View
    autoload :Base, 'tipsy/view/base'
  end
  
  module Compressors
    autoload :CssCompressor, 'tipsy/compressors/css'
    autoload :JavascriptCompressor, 'tipsy/compressors/javascript'
  end
  
  module Sass
    autoload :Template, 'tipsy/sass/template'
  end
  
  mattr_accessor :root
  mattr_accessor :logger
  mattr_accessor :env
  mattr_accessor :sprockets
  mattr_accessor :compass
  
  def self.logger
    @logger ||= Tipsy::Logger.new($stdout)
  end
    
  def self.run_command(args, stdin)    
    args   = [args].flatten    
    to_run = args.first
    to_run = case to_run
    when nil then 'run'
    when 'new' then 'create'
    when 'serve' || 's' then 'run'
    else to_run
    end
    args.shift
    parse_options!    
    Tipsy::Application.send(:"#{to_run}", *args)    
    
  end
  
  def self.options
    @@options ||= Tipsy::Configuration.create!
  end
  
  class << self
    alias :config :options
  end
  
  private
  
  def self.parse_options!  
  
    op = OptionParser.new do |opts|
      opts.banner = "Usage: tipsy [cmd] [options]"
      opts.separator ""
      opts.separator "Options:"
      opts.on("-p", "--port", "Run the server on a specified port ( default: 4000 )") do |port|
        options.port = port
      end
      opts.on("-a", "--address", "Run the server on a specified address ( default: 0.0.0.0 )") do |host|
        options.host = host
      end
      opts.on_tail("--version", "Show version") do
        puts Tipsy::VERSION
        exit 0
      end
    end
    
  end
  
end
