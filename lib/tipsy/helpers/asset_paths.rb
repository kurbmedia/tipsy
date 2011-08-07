require 'pathname'

module Tipsy
  module Helpers
    module AssetPaths
      
      def asset_path(path)
        return path if path.match(/^https?:/) || Pathname.new(path).absolute?
        "/" << File.join('assets', path)
      end
      
      def path_with_ext(path, ext)
        return path if path.match(/^https?:/) || path.ends_with?(".#{ext}")
        [path, ext].join('.')
      end
    
    end
  end
end