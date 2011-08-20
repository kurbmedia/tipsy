require 'tipsy'
require 'active_support/ordered_options'

##
# Default options
#
Tipsy::Site.config.public_path = File.join(Tipsy.root, 'public')
Tipsy::Site.config.assets = ::ActiveSupport::OrderedOptions.new
Tipsy::Site.config.assets.paths = []
Tipsy::Site.config.assets.javascripts_path = '/assets'
Tipsy::Site.config.assets.images_path      = '/assets'
Tipsy::Site.config.assets.css_path        = '/assets'
