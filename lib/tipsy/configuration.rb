CONFIGURATION_OPTIONS = [
  :port,          # Port to run the server on
  :address,       # Host to run the server on
  :assets,        # Two options: paths is an array of load paths, precompile is an array of files to compress on build
  :build_path,    # Path where files will be exported
  :public_path,   # Path to the public directory for the site
  :asset_path,    # Path to http assets path as well as the build path
  :compass,       # References compass config
  :output,        # Settings for output/export
  :remote         # Options for connecting to a remote ftp/sftp server when exporting
]

module Tipsy
  class Configuration < Struct.new(*CONFIGURATION_OPTIONS)
    
    def self.create!
      opts = self.new
      opts.port         = 4000
      opts.address      = '0.0.0.0'
      opts.assets       = Assets.new([], [])
      opts.build_path   = File.join(Tipsy.root, 'build')
      opts.public_path  = File.join(Tipsy.root, 'public')
      opts.asset_path   = File.join(Tipsy.root, 'assets')
      opts.compass      = Compass.new

      opts.compass.project_type     = :stand_alone
      opts.compass.project_path     = Tipsy.root
      opts.compass.sass_dir         = File.join('assets', 'stylesheets')
      opts.compass.http_images_path = "/#{File.basename(opts.asset_path)}"
      opts.compass.relative_assets  = false
      
      opts.output = Output.new(true, []) 
      opts.remote = Remote.new(nil, nil, nil, 21, nil)
            
      opts
    end
    
    class Assets < Struct.new(:paths, :precompile); end
    class Compass < Struct.new(:project_type, :project_path, :sass_dir, :http_images_path, :relative_assets); end
    class Output < Struct.new(:sitemap, :ignore_paths)
    class Remote < Struct.new(:host, :username, :password, :port, :path)
    
  end
end