# Thoran/String/Urlencode/urlencode.rb
# Thoran::String::Urlencode#urlencode

# 20260713
# 0.4.0

# Acknowledgements: I've simply ripped off and refashioned the code from the CGI module!...

# Changes since 0.3:
# -/0: More consistent naming.
# 1. /UrlEncode/Urlencode/
# 2. /url_encode/urlencode/

module Thoran
  module String
    module Urlencode

      def urlencode
        self.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
          '%' + $1.unpack('H2' * $1.size).join('%').upcase
        end.tr(' ', '+')
      end
      alias_method :url_encode, :urlencode

    end
  end
end

String.send(:include, Thoran::String::Urlencode)
