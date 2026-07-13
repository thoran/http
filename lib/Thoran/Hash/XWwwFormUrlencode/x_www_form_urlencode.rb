# Thoran/Hash/XWwwFormUrlencode/x_www_form_urlencode.rb
# Thoran::Hash::XWwwFormUrlencode#x_www_form_urlencode

# 20260713
# 0.3.0

# Changes since 0.2:
# -/0: (The class name and the snake case name really are consistent now.)
# 1. /XWwwFormUrlEncode/XWwwFormUrlencode/
# 2. /url_encode/urlencode/

require 'Thoran/String/Urlencode/urlencode'

module Thoran
  module Hash
    module XWwwFormUrlencode

      def x_www_form_urlencode(joiner = '&')
        inject([]){|a,e| a << "#{e.first.to_s.urlencode}=#{e.last.to_s.urlencode}" unless e.last.nil?; a}.join(joiner)
      end
      alias_method :x_www_form_url_encode, :x_www_form_urlencode

    end
  end
end

Hash.send(:include, Thoran::Hash::XWwwFormUrlencode)
