require 'pathname'

module Tipsy
  module Helpers
    module AssetPaths
      
      def asset_path(path)
        return path if path.match(/^https?:/) || Pathname.new(path).absolute?
        "/" << path_for_asset_type(path)
      end
      
      def path_with_ext(path, ext)
        return path if path.match(/^https?:/) || path.ends_with?(".#{ext}")
        [path, ext].join('.')
      end
      
      private
      
      def path_for_asset_type(path)
        result = if is_javascript?(path)
          File.join(Tipsy::Site.javascripts_path, path)
          elsif is_css?(path)
            File.join(Tipsy::Site.css_path, path)
          elsif is_image?(path)
            File.join(Tipsy::Site.images_path, path)
          else 
            File.join(Tipsy::Site.asset_path, path)
        end
        result = (Pathname.new(result).absolute? ? result.sub("/",'') : result)
        result
      end
      
      def is_image?(path)
        !!(['.png', '.jpg', '.jpeg', '.gif', '.svg', '.bmp'].detect{ |p| path.ends_with?(p) })
      end
      
      def is_css?(path)
        path.ends_with?('.css')
      end
      
      def is_javascript?(path)
        path.ends_with?(".js")
      end
    
    end
  end
end