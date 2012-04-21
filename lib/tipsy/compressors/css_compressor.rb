require 'sass'

module Tipsy
  module Compressors
    class CssCompressor
      def compress(css)
        css_style = Tipsy::Site.config.compile.compress_css ? :compressed : :compact
        Sass::Engine.new(css, :syntax => :scss, :cache => false, :read_cache => false, :line_comments => false, :style => css_style).render
      end
    end
  end
end
