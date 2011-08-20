require 'tipsy/site/utils'
require 'erb'

module Tipsy
  class Creator
    include Tipsy::Utils::System
    
    attr_reader :project
      
    def initialize(name)
      @project      = name.camelize
      @dest_path    = File.join(Tipsy.root, name.underscore)
      @source_path  = File.expand_path("../../project", __FILE__)        
      create_project!
    end
    
    def create_project!    
      FileUtils.mkdir(dest_path) unless File.exists?(dest_path)
      cvars = Conf.new
      cvars.root      = dest_path
      cvars.classname = @project              
      template        = File.read(File.join(source_path, 'config.erb'))
      config          = ERB.new(template).result(cvars.get_binding)

      File.open(File.join(dest_path, 'config.rb'), 'w'){ |io| io.write(config) }
      log_action('create', File.join(dest_path, 'config.rb'))
    
      Tipsy.logger.info("\n   Project #{project} created in #{dest_path}.")
      Tipsy.logger.info("   Run 'tipsy' from the root folder to start the server.\n\n")
    
    end
  
    class Conf
      attr_accessor :classname, :root
      def get_binding; binding; end
    end
    
  end
end