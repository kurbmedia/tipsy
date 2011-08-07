require "tipsy/version"
require "active_support/all"
require 'optparse'
require 'ostruct'

module Tipsy

  autoload :Application,  'tipsy/application'
  autoload :Server,       'tipsy/server'
  autoload :Responder,    'tipsy/handler'
  autoload :View,         'tipsy/view'
  autoload :Helpers,      'tipsy/helpers'  
  autoload :Builder,      'tipsy/builder'
  autoload :Logger,       'tipsy/logger'
  
  module Compressors
    autoload :CssCompressor, 'tipsy/compressors/css'
    autoload :JavascriptCompressor, 'tipsy/compressors/javascript'
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
    @@options ||= OpenStruct.new({
      :port         => 4000,
      :host         => '0.0.0.0',
      :assets       => [],
      :build_path   => File.join(Tipsy.root, 'build'),
      :public_path  => File.join(Tipsy.root, 'public'),
      :asset_path   => File.join(Tipsy.root, 'public', 'assets')
    })
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
