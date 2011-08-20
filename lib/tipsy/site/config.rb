require 'tipsy'
require 'active_support/ordered_options'

##
# Default options
#
Tipsy::Site.config.port         = 4000
Tipsy::Site.config.address      = '0.0.0.0'
Tipsy::Site.config.public_path  = File.join(Tipsy.root, 'public')
Tipsy::Site.config.assets       = ::ActiveSupport::OrderedOptions.new
Tipsy::Site.config.assets.paths = []

Tipsy::Site.config.assets.javascripts_path = '/assets'
Tipsy::Site.config.assets.images_path      = '/assets'
Tipsy::Site.config.assets.css_path         = '/assets'
