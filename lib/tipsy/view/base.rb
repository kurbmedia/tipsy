require 'tipsy/view/errors'
require 'hike'
require 'tilt'

module Tipsy
  class View
    attr_reader :view_path, :request
    
    def initialize(path, req)
      @view_path = path
      @request   = req
    end
    
    def view_context
      @_view_context ||= Class.new(self)
        include Tipsy::Helpers
      end
    end
    
  end
end