# Thoran/Array/FirstX/firstX.rb
# Thoran::Array::FirstX#first!

# 20180804
# 0.3.3

# Description: Sometimes it makes more sense to treat arrays this way.

# Changes since 0.2:
# 1. Added the original version 0.1.0 of the implementation to the later 0.1.0!
# 0/1
# 2. Switched the tests to spec-style.
# 1/2
# 3. Added a test for the state of the array afterward, since this is meant to be an in place change.
# 2/3
# 4. Added tests for the extended functionality introduced in the first version 0.1.0.

module Thoran
  module Array
    module FirstX

      def first!(n = 1)
        return_value = []
        n.times{return_value << self.shift}
        return_value.size == 1 ? return_value[0] : return_value
      end

    end
  end
end

Array.send(:include, Thoran::Array::FirstX)
