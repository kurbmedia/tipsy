# Configure urls where assets are to be served. 
# In development, assets should be placed under root_path/assets
# On compile, assets will be stored at these locations (defaults shown)
#
asset_path       = "/assets"
javascripts_path = "/assets"
images_path      = "/assets"
css_path         = "/assets"

# Fonts don't really need to be served by sprockets, they should go in your public_path. 
# This option is mostly provided for using asset_url helpers in Sass
fonts_path       = "/fonts"

# On compile, use this folder. Accepts either a relative or absolute path
compile_to  = "compiled"

# Static files and assets will be served from this location
public_path = "public"

# Configure assets to be compiled at compile-time (default: screen.css and site.js)
#
compile.assets << "site.js"
compile.assets << "screen.css"

# By default template compilation will generate files as they exist in your /views directory. 
# This allows for rewriting via .htaccess or nginx config to avoid .html extensions in your urls.
# If you would prefer a folder/index.html structure for the resulting html files, set compile.enable_rewrite to false.
# Set compile.rewrite_mode to one of :nginx or :htaccess to have a .htaccess/nginx.conf file generated for you.
# The default configurations are shown below
# 
# compile.enable_rewrite = true
# compile.rewrite_mode   = :htaccess

# Compiling cleans the 'compile_to' path prior to re-building the site. 
# To ensure certain directories are preserved, add them here. This is primarily useful for scm directories
#
# compile.preserve << ".svn"
# 
# When compiling, all files and folders found in the 'public_path' are copied. To ignore 
# specific files or folders, include them here.
# 
# compile.skip << "some-path"
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