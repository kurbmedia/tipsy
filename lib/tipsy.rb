require "active_support/all"
require 'active_support/inflector'
require 'tipsy/version'
require 'tipsy/logging'

module Tipsy
  mattr_accessor :root
  
  autoload :View,           'tipsy/view/base'
  autoload :Server,         'tipsy/server'
  autoload :Helpers,        'tipsy/helpers'
  autoload :Site,           'tipsy/site'
  autoload :ServerLogger,   'tipsy/loggers/server'
  
  module Compressors
    autoload :Javascipt, 'tipsy/compressors/javascript'
    autoload :Css,       'tipsy/compressors/css'
  end
  
  def self.options
    Tipsy::Site.config
  end

  def self.logger
    @logger ||= Tipsy::Logger.new($stdout)
  end
  
  def self.env
    @env ||= (ENV['TIPSY_ENV'] || 'development')
  end
   
end
