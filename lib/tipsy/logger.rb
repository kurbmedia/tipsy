require 'logger'

module Tipsy
  class Logger < ::Logger
    
    def initialize
      super($stdout)
    end
    
  end
end