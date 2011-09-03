module Tipsy
  class Configuration < ActiveSupport::OrderedHash
    
    def initialize(*args)
      super(*args)
    end
    
  end
end