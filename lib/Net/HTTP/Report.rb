# Net/HTTP/Report.rb
# Net::HTTP::Report

require 'net/http'

module Net
  class HTTP
    class Report < Net::HTTPRequest
      METHOD = 'REPORT'
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
    end
  end
end
