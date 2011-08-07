$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "rack/test"
require "test/unit"
require "minitest/unit"
require "turn"
require "tipsy"
require 'matchy'

module Tipsy
  module Test
    
    def self.app
      @app ||= Tipsy::Server.init!
    end
  
    module Helpers
      
      def to_html(string)
        string.strip
      end
      
      def fixture(name)
        path = File.join(File.expand_path('../fixtures', __FILE__), name)
        File.read(path).to_s.strip
      end
      
    end
    
  end
  
end

Tipsy.root = File.join(File.dirname(__FILE__), '.', 'root', 'test')