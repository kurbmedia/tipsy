require 'active_support/inflector'

module Tipsy
  class Builder
    
    attr_reader :build_path
    
    def initialize(path)
      @build_path = path
    end
    
  end
end