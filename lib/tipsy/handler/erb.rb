require "erubis"
##
# The ErbHandler hacks erubis in the same manner as Rails.
# This allows support for Rails view helpers. 
# 
module Tipsy
  module Handler
    class ErbHandler < ::Tilt::ErubisTemplate
    end
  end
end

class Erubis::Eruby
  def add_text(src, text)
    return if text.empty? || text.nil?
    src << "@output_buffer.concat('" << escape_text(text) << "');"
  end

  BLOCK_EXPR = /\s+(do|\{)(\s*\|[^|]*\|)?\s*\Z/

  def add_expr_literal(src, code)
    return if code.nil?
    if code.to_s =~ BLOCK_EXPR
      src << '@output_buffer << ' << code.to_s
    else
      src << '@output_buffer << (' << code.to_s << ');'
    end
  end

  def add_expr_escaped(src, code)
    return if code.nil?
    if code.to_s =~ BLOCK_EXPR
      src << "@output_buffer << " << code.to_s
    else
      src << "@output_buffer.concat((" << code.to_s << ").to_s);"
    end
  end

  def add_postamble(src)
    src << '@output_buffer.to_s'
  end
end