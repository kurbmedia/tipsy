require 'tipsy'
require 'active_support/ordered_options'

##
# Default options
#
module Tipsy
  class Site
  
    def self.configure_defaults!
      config.port         = 4000
      config.address      = '0.0.0.0'
      config.public_path  = File.join(Tipsy.root, 'public')
      config.assets       = ::ActiveSupport::OrderedOptions.new
      config.assets.paths = []
      config.asset_path   = '/assets'
      config.assets.precompile       = []
      config.assets.javascripts_path = config.asset_path
      config.assets.images_path      = config.asset_path
      config.assets.css_path         = config.asset_path
    end
    
  end
end

Tipsy::Site.configure_defaults!

local_config = File.join(Tipsy.root, 'config.rb')
if File.exists?(local_config)
  require local_config
end