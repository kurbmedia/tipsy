# Configure urls where assets are to be served. 
# In development, assets should be placed under root_path/assets
# On compile, assets will be stored at these locations
#
asset_path       = "/assets"
javascripts_path = "/assets"
images_path      = "/assets"
css_path         = "/assets"
fonts_path       = "/fonts"

# On compile, use this folder. Accepts either a relative or absolute path
compile_to  = "compiled"

# Static files and assets will be served from this location
public_path = "public"

# Configure assets to be compiled at compile-time (default: screen.css and site.js)
#
compile.assets << "site.js"
compile.assets << "screen.css"

# Compiling cleans the 'compile_to' path prior to re-building the site. 
# To ensure certain directories are preserved, add them here. This is primarily useful for scm directories
#
# compile.preserve << ".git"
# 
# When compiling, all files and folders found in the 'public_path' are copied. To ignore 
# specific files or folders, include them here.
# 
# compile.skip << "path_to_skip"
# 
# 
# Callbacks:
# To perform additional tasks either before or after compilation, define either a 
# before_compile, after_compile, or both. Blocks are passed an instance of the Compiler.
# See tipsy/runners/compiler.rb for more info.
# 
# after_compile do |runner|
# end
# 