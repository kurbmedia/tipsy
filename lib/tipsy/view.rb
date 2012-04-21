require 'tipsy/handler/all'
require 'tilt'
require 'hike'

module Tipsy
  module View 
    class << self
      def register_handler(klass, ext)
        Tilt.register(klass, ext)
      end
    end
    
    class TemplateMissing < ::StandardError; end
    class LayoutMissing < ::StandardError; end
    
  end
end

require 'tipsy/helpers'
require 'tipsy/view/base'
require 'tipsy/view/context'
require 'tipsy/view/path'

#Tipsy::View.register_handler(Tipsy::Handler::PhpHandler, 'php.erb')
Tipsy::View.register_handler(Tipsy::Handler::ErbHandler, 'erb')