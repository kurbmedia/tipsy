require 'tilt'

module Tipsy
  class Generator
    
    attr_reader :project_class, :dest_path, :source_path
    
    def self.create_project!(name)
      self.new(File.join(Tipsy.root, name.underscore), name.camelize)
    end
    
    def initialize(dir, klass)
      Tipsy.root     = dir
      @project_class = klass
      
      @dest_path   = dir
      @source_path = File.join(File.dirname(__FILE__), 'project')
      generate!
    end

    def generate!
      FileUtils.mkdir(dest_path) unless File.exists?(dest_path)
      copy_source(source_path, dest_path)
      config = Tilt.new(File.join(source_path, 'config.erb'), nil)
      config = config.render(Object.new, {
        :classname => @project_class,
        :root      => dest_path
      })
      File.open(File.join(dest_path, 'config.rb'), 'w'){ |io| io.write(config) }
    end
    
    private
    
    def copy_source(src, dest)
      
      Dir.foreach(src) do |file|
        next if file == '.' || file == '..' || file == 'config.erb'
        
        source = File.join(src, file)
        copyto = File.join(dest, file)
      
        if File.directory?(source)
          FileUtils.mkdir(copyto)
          copy_source(source, copyto)
        else
          FileUtils.cp(source, copyto)
        end
      end
      
    end
    
  end
end