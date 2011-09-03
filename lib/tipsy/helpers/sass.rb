require 'sass'

module Tipsy
  module Helpers
    module Sass

      def asset_path(asset, kind)
        ::Sass::Script::String.new(public_path(asset, kind), true)
      end

      def asset_url(asset, kind)
        ::Sass::Script::String.new(%Q{url(#{asset_path(asset, kind)})})
      end

      [:image, :font, :stylesheet].each do |asset_class|
        class_eval %Q{
          def #{asset_class}_path(asset)
            asset_path(asset, ::Sass::Script::String.new("#{asset_class}"))
          end
          def #{asset_class}_url(asset)
            asset_url(asset, ::Sass::Script::String.new("#{asset_class}"))
          end
        }, __FILE__, __LINE__ - 6
      end

    protected
      def public_path(asset, kind)
        
        check = ::Pathname.new(asset.to_s)
        return asset.to_s if check.absolute?
        
        path = case kind.to_s        
        when 'stylesheet' || 'css' then Tipsy::Site.css_path
        when 'javascript' || 'js'  then Tipsy::Site.javascripts_path
        when 'image' || 'images'  then Tipsy::Site.images_path
        when 'font'  || 'fonts'    then Tipsy::Site.fonts_path
        else "/"
        end
        path.to_s
      end
    end
  end
end

module Sass
  module Script
    module Functions
      include Tipsy::Helpers::Sass
    end
  end
end