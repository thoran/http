# Thoran/Hash/XWwwFormUrlencode/x_www_form_urlencode.rb
# Thoran::Hash::XWwwFormUrlencode#x_www_form_urlencode

# 20261019
# 0.3.1

# Changes since 0.2:
# -/0: (The class name and the snake case name really are consistent now.)
# 1. /XWwwFormUrlEncode/XWwwFormUrlencode/
# 2. /url_encode/urlencode/
# 0/1: An array value repeats its key for each element.
# 3. ~ x_www_form_urlencode: an array value gives a pair for each of its elements, as URI.encode_www_form does, rather than one pair holding the array's inspect string, '[1, 2]'; a nil element is left out, as a nil value is.

require 'Thoran/String/Urlencode/urlencode'

module Thoran
  module Hash
    module XWwwFormUrlencode

      def x_www_form_urlencode(joiner = '&')
        inject([]) do |a,(key, value)|
          (value.is_a?(Array) ? value : [value]).each do |element|
            a << "#{key.to_s.urlencode}=#{element.to_s.urlencode}" unless element.nil?
          end
          a
        end.join(joiner)
      end
      alias_method :x_www_form_url_encode, :x_www_form_urlencode

    end
  end
end

Hash.send(:include, Thoran::Hash::XWwwFormUrlencode)
