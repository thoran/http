# HTTP/RETRY.rb
# HTTP::RETRY (retry helpers)

require 'net/http'
require 'socket'
require 'time'

module HTTP
  module RETRY
    EXCEPTIONS = [
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::ETIMEDOUT,
      Errno::EHOSTUNREACH,
      Errno::ENETUNREACH,
      Net::OpenTimeout,
      Net::ReadTimeout,
      SocketError,
      EOFError
    ].freeze
    STATUS_CODES = [429, 502, 503, 504].freeze
    VERBS = %i{get head options put delete trace}.freeze

    def self.sleep(seconds)
      Kernel.sleep(seconds)
    end
  end

  def retry_config(options)
    {
      retries: options.delete(:retries) || 0,
      delay: options.delete(:retry_delay) || 1.0,
      status_codes: options.delete(:retry_status_codes) || RETRY::STATUS_CODES,
      exceptions: options.delete(:retry_exceptions) || RETRY::EXCEPTIONS,
      verbs: options.delete(:retry_verbs) || RETRY::VERBS
    }
  end
  module_function :retry_config

  def with_retries(http, request_object, config)
    attempt = 0
    loop do
      begin
        response = http.request(request_object)
        if config[:status_codes].include?(response.code.to_i) && attempt < config[:retries]
          attempt += 1
          RETRY.sleep(retry_after(response) || backoff_delay(config[:delay], attempt))
          next
        end
        return response
      rescue *config[:exceptions]
        raise unless attempt < config[:retries]
        attempt += 1
        RETRY.sleep(backoff_delay(config[:delay], attempt))
      end
    end
  end
  module_function :with_retries

  def backoff_delay(base, attempt)
    base * (2 ** (attempt - 1)) * (1 + (rand - 0.5) * 0.4)
  end
  module_function :backoff_delay

  def retry_after(response)
    header = response['Retry-After']
    return nil unless header
    if header =~ /\A\d+\z/
      header.to_i
    else
      # Malformed HTTP-date — fall through to caller's backoff.
      Time.httpdate(header) - Time.now rescue nil
    end
  end
  module_function :retry_after
end
