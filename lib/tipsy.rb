require "active_support/all"
require "tipsy/version"

module Tipsy
  
  module Handler    
    autoload :AssetHandler,    'tipsy/handler/asset'
    autoload :StaticHandler,   'tipsy/handler/static'
    autoload :SassHandler,     'tipsy/handler/sass'
    autoload :PhpHandler,      'tipsy/handler/php'
    autoload :ErbHandler,      'tipsy/handler/erb'
  end
  
  module Runners
    autoload :Generator, 'tipsy/runners/generator'
    autoload :Compiler,  'tipsy/runners/compiler'
    autoload :Deployer,  'tipey/runners/deployer'
  end
  
  module Utils
    autoload :System,     'tipsy/utils/system'
    autoload :SystemTest, 'tipsy/utils/system_test'
    autoload :Logger,     'tipsy/utils/logger'
  end
  
  module Compressors
    autoload :JavascriptCompressor, 'tipsy/compressors/javascript_compressor'
    autoload :CssCompressor,        'tipsy/compressors/css_compressor'
  end
  
  class << self    
    def env
      @env ||= ENV['TIPSY_ENV'] || 'development'
    end
    
    def root
      @root ||= ENV['TIPSY_ROOT']
    end
    
    def logger
      @logger ||= Tipsy::Utils::Logger.new($stdout)
    end    
  end

end

require 'tipsy/site'