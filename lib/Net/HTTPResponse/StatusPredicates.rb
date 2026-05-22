# Net/HTTPResponse/StatusPredicates.rb
# Net::HTTPResponse::StatusPredicates

module Net
  class HTTPResponse
    module StatusPredicates
      def informational?
        @code =~ /^1/  ? true : false
      end

      def successful?
        @code =~ /^2/ ? true : false
      end
      alias_method :success?, :successful?

      def ok?
        @code == '200'
      end

      def redirection?
        @code =~ /^3/ ? true : false
      end

      def client_error?
        @code =~ /^4/ ? true : false
      end

      def server_error?
        @code =~ /^5/ ? true : false
      end

      def error?
        client_error? || server_error?
      end
    end
  end
end

Net::HTTPResponse.include(Net::HTTPResponse::StatusPredicates)
