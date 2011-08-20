module Tipsy
  module Helpers
    module AssetTags
      
      def image_tag(src, html_attrs = {})
        html_attrs.stringify_keys!
        html_attrs.reverse_merge!('alt' => File.basename(src))
        tag(:img, html_attrs.merge('src' => asset_path(src)))
      end
      
      def javascript_include_tag(*files)        
        html_attrs = files.extract_options!
        html_attrs.stringify_keys!
        files.map{ |file| 
          content_tag('script', '', {'src' => asset_path(path_with_ext(file, 'js'))}.merge!(html_attrs))
        }.join("\n")
      end
      
      def stylesheet_link_tag(*files)        
        html_attrs = files.extract_options!
        html_attrs.reverse_merge!({          
          :media => "screen"
        }).stringify_keys!
        
        files.map{ |file| 
          tag('link', { 'href' => asset_path(path_with_ext(file, 'css')), 'rel' => "stylesheet" }.merge!(html_attrs))
        }.join("\n")
      end
      
    end
  end
end