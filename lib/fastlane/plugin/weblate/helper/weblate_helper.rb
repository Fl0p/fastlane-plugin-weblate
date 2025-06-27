require 'fastlane_core/ui/ui'
require 'net/http'
require 'uri'
require 'json'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class WeblateHelper
      # class methods that you define here become available in your action
      # as `Helper::WeblateHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the weblate plugin helper!")
      end

      # Build base API URL from host parameter
      def self.build_api_base_url(host)
        uri = URI(host)
        base_url = "#{uri.scheme}://#{uri.host}"
        base_url += ":#{uri.port}" if uri.port != uri.default_port
        base_url += uri.path.empty? ? '/api' : uri.path
        base_url
      end

      # Create and configure HTTP client
      def self.create_http_client(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http
      end

      # Create HTTP GET request with common headers
      def self.create_request(uri, api_token)
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Token #{api_token}"
        request['Accept'] = 'application/json'
        request['User-Agent'] = 'fastlane-plugin-weblate'
        request
      end

      # Handle common HTTP response errors
      def self.handle_response_errors(response)
        case response.code.to_i
        when 401
          UI.error("❌ Authentication failed. Please check your API token.")
          raise "Authentication failed (401)"
        when 403
          UI.error("❌ Access forbidden. Check your permissions.")
          raise "Access forbidden (403)"
        when 404
          UI.error("❌ Resource not found. Please check your parameters.")
          raise "Resource not found (404)"
        when 429
          UI.error("❌ Too many requests. Please wait and try again.")
          raise "Rate limit exceeded (429)"
        when 200
          # Success - no error handling needed
          return
        else
          UI.error("❌ API request failed with status: #{response.code}")
          UI.error("Response: #{response.body}")
          raise "API request failed (#{response.code})"
        end
      end

      # Make HTTP request with error handling
      def self.make_api_request(api_url, api_token, success_message = nil)
        UI.message("📡 API URL: #{api_url}")
        
        begin
          uri = URI(api_url)
          http = create_http_client(uri)
          request = create_request(uri, api_token)
          
          response = http.request(request)
          handle_response_errors(response)
          
          UI.success(success_message) if success_message
          
          # Parse and return JSON response
          JSON.parse(response.body)
          
        rescue JSON::ParserError => e
          UI.error("❌ Failed to parse JSON response: #{e.message}")
          raise e
        rescue StandardError => e
          UI.error("❌ Unexpected error: #{e.message}")
          raise e
        end
      end
    end
  end
end
