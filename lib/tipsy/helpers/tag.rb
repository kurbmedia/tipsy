module Tipsy
  module Helpers
    
    module Tag
      include Capture
      
      def tag(name, html_attrs = {}, open = false)
        "<#{name}#{make_attributes(html_attrs)}#{open ? ">" : " />"}"
      end
      
      def content_tag(name, content = nil, html_attrs = {}, &block)
        buffer = "<#{name}#{make_attributes(html_attrs)}>"
        content = capture(&block) if block_given?
        "<#{name}#{make_attributes(html_attrs)}>#{content}</#{name}>"
      end
      
      def link_to(text, path, html_attrs = {})
        content_tag(:a, text, html_attrs.merge!('href' => path))
      end
      
      def mail_to(addr, text = nil, html_attrs = {})
        unless text || text.is_a?(Hash)
          html_attrs = text if text
          text = addr
        end
        link_to(text, "mailto:#{addr}", html_attrs)
      end
      
      private
      
      def make_attributes(hash)
        attrs = []
        hash.each_pair do |key, value|
          attrs << "#{key}=#{value.inspect}"
        end
        (attrs.empty? ? "" : " #{attrs.join(" ")}")
      end
      
    end
    
  end
end