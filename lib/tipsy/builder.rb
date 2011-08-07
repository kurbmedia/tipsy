require 'active_support/inflector'

##
# Handles building source files into a final project, for 
# either deployment or output to a directory
# 
module Tipsy
  module Builder
    
    autoload :Base,           'tipsy/builders/base'
    autoload :ProjectBuilder, 'tipsy/builders/project'
    autoload :ExportBuilder,  'tipsy/builders/local'
    autoload :RemoteBuilder,  'tipsy/builders/remote'
    
    def self.build!(type = :project, *args)
      handler = case type
        when :project then ProjectBuilder.new(*args)
        when :export  then ExportBuilder.new(*args)
        when :remote  then RemoteBuilder.new(*args)
        else raise 'No builder specified'
      end
      handler.build!
    end
    
  end
end