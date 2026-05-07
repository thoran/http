# Thoran/String/ToConst/to_const.rb
# Thoran::String::ToConst#to_const

# 20141223
# 0.2.0

# Description: This takes a string and returns a constant, with unlimited namespacing.

# History: Derived from Object#to_const 0.3.0, and superceding Object#to_const.

# Changes:
# 1. + Thoran namespace.

# Todo:
# 1. This only works for two levels of constants.  Three and you're stuffed.  So, this needs to be recursive...
#   Done iteratively as of 0.1.0.
# 2. Make this work for symbols.  However, this will only work if there's no namespacing.  ie. :A is OK, but :A::B is not.

# Discussion:
# 1. Should this go separately into classes for which ::const_get will work and be removed from Object?  Done as of 0.1.0.

require 'Thoran/Array/AllButFirst/all_but_first'

module Thoran
  module String
    module ToConst

      def to_const
        if self =~ /::/
          constants = self.split('::')
          constant = Object.const_get(constants.first)
          constants = constants.all_but_first
          until constants.empty? do
            constant = constant.const_get(constants.shift)
          end
        else
          constant = Object.const_get(self)
        end
        constant
      end
      alias_method :to_constant, :to_const

    end
  end
end

String.send(:include, Thoran::String::ToConst)
