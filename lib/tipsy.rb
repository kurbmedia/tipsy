require "active_support/all"
require 'active_support/inflector'
require 'optparse'

require 'tipsy/version'
require 'tipsy/site'
require 'tipsy/logger'

module Tipsy
  
  autoload :View,     'tipsy/view/base'
  autoload :Server,   'tipsy/server'
  autoload :Helpers,  'tipsy/helpers'
  
  module Compressors
    autoload :Javascipt, 'tipsy/compressors/javascript'
    autoload :Css,       'tipsy/compressors/css'
  end
  
  mattr_accessor :root

  def self.logger
    @logger ||= Tipsy::Logger.new($stdout)
  end
  
  def self.env
    @env ||= (ENV['TIPSY_ENV'] || 'development')
  end
   
end
