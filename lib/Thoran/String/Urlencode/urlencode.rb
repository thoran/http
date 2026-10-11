# Thoran/String/Urlencode/urlencode.rb
# Thoran::String::Urlencode#urlencode

# 20261011
# 0.4.1

# Acknowledgements: I've simply ripped off and refashioned the code from the CGI module!...

# Changes since 0.3:
# -/0: More consistent naming.
# 1. /UrlEncode/Urlencode/
# 2. /url_encode/urlencode/
# 0/1: Non-ASCII is encoded in full, and without a warning.
# 3. /$1.size/$1.bytesize/: unpack('H2' * $1.size) took one byte per character, so only the first byte of a multibyte character was encoded and 'Älaskår' became '%C3lask%C3r'.
# 4. - /n flag: a binary regexp matched against a UTF-8 string warns on current Ruby (seen on 4.0.5), and the match is the same without it.

module Thoran
  module String
    module Urlencode

      def urlencode
        self.gsub(/([^ a-zA-Z0-9_.-]+)/) do
          '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
        end.tr(' ', '+')
      end
      alias_method :url_encode, :urlencode

    end
  end
end

String.send(:include, Thoran::String::Urlencode)
