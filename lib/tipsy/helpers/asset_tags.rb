module Tipsy
  module Helpers
    module AssetTags
      include Tag
      include AssetPaths
      
      def javascript_include_tag(*files)        
        html_attrs = extract_options!(files)
        files.map{ |file| 
          content_tag('script', '', {'src' => asset_path(path_with_ext(source, 'js'))}.merge!(html_attrs))
        }.join("\n")
      end
      
      def stylesheet_link_tag(*files)        
        html_attrs = extract_options!(files)
        files.map{ |file| 
          content_tag('link', '', {'href' => asset_path(path_with_ext(source, 'css'))}.merge!(html_attrs))
        }.join("\n")
      end
      
    end
  end
end