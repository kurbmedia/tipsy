module Tipsy
  module Builder
    
    class RemoteBuilder < Base
      
      def initialize
        @source_path = Tipsy.root
        @dest_path   = ''
      end
      
    end
    
  end
end