module Tipsy
  module Builder
    class ProjectBuilder < Base
      attr_reader :project
      
      def initialize(name)
        @project      = name.camelize
        @dest_path    = File.join(Tipsy.root, name.underscore)
        @source_path  = File.expand_path("../../project", __FILE__)        
      end
      
      def build!
        FileUtils.mkdir(dest_path) unless File.exists?(dest_path)
        super
        
        config = Tilt.new(File.join(source_path, 'config.erb'), nil)
        config = config.render(Object.new, {
          :classname => @project,
          :root      => dest_path
        })
        
        File.open(File.join(dest_path, 'config.rb'), 'w'){ |io| io.write(config) }
        log_action('create', File.join(dest_path, 'config.rb'))
        
        Tipsy.logger.info("\n   Project #{project} created in #{dest_path}.")
        Tipsy.logger.info("   Run 'tipsy' from the root folder to start the server.\n\n")
        
      end
      
    end
  end
end