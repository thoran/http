# Thoran/Array/AllButFirst/all_but_first.rb
# Thoran::Array::AllButFirst#all_but_first

# 20141223
# 0.1.0

# Description: This returns a copy of the receiving array with the first element removed.  

# Changes:
# 1. + Thoran namespace.

require 'Thoran/Array/FirstX/firstX'

module Thoran
  module Array
    module AllButFirst

      def all_but_first
        d = self.dup
        d.first!
        d
      end

    end
  end
end

Array.send(:include, Thoran::Array::AllButFirst)
