require 'fastlane/action'
require_relative '../helper/weblate_helper'
require 'net/http'
require 'uri'
require 'json'
require 'ostruct'

module Fastlane
  module Actions
    class WeblateProjectsLanguagesAction < Action
      def self.run(params)
        begin
          # Parse URL components
          uri = URI(params[:host])
          base_url = "#{uri.scheme}://#{uri.host}"
          base_url += ":#{uri.port}" if uri.port != uri.default_port
          base_url += uri.path.empty? ? '/api' : uri.path
          
          # Build API endpoint URL
          api_url = "#{base_url}/projects/#{params[:project_slug]}/languages/"
          
          UI.message("🌐 Connecting to Weblate: #{params[:host]}")
          UI.message("🔍 Fetching languages for project: #{params[:project_slug]}")
          UI.message("📡 API URL: #{api_url}")
          
          # Make HTTP request
          uri = URI(api_url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme == 'https'
          
          request = Net::HTTP::Get.new(uri)
          request['Authorization'] = "Token #{params[:api_token]}"
          request['Accept'] = 'application/json'
          request['User-Agent'] = 'fastlane-plugin-weblate'
          
          response = http.request(request)
          
          case response.code.to_i
          when 200
            UI.success("✅ Successfully fetched project languages!")
            
            # Parse JSON response
            result = JSON.parse(response.body)
            
            # Handle different possible response structures
            languages_data = if result.is_a?(Hash) && result['results']
                              result['results'] || []
                            elsif result.is_a?(Array)
                              result
                            else
                              []
                            end
            
            # Convert hash data to objects with attribute access
            languages = languages_data.map do |lang_data|
              OpenStruct.new(
                name: lang_data['name'] || lang_data['english_name'] || 'Unknown',
                code: lang_data['code'] || 'Unknown',
                direction: lang_data['direction'],
                plural: lang_data['plural'],
                web_url: lang_data['web_url'],
                url: lang_data['url']
              )
            end
            
            UI.message("🌍 Found languages: #{languages.count}")
            
            if params[:show_details] && !languages.empty?
              UI.message("\n🌍 Language details:")
              languages.each_with_index do |language, index|
                UI.message("#{index + 1}. #{language.name} (#{language.code})")
                
                if language.direction
                  UI.message("   Direction: #{language.direction}")
                end
                if language.plural
                  UI.message("   Plural count: #{language.plural}")
                end
                UI.message("")
              end
            elsif params[:show_details] && languages.empty?
              UI.message("📝 No languages found for this project")
            end
            
            # Return processed languages for further use
            languages
            
          when 401
            UI.error("❌ Authentication failed. Please check your API token.")
            raise "Authentication failed (401)"
          when 403
            UI.error("❌ Access forbidden. Check your permissions for this project.")
            raise "Access forbidden (403)"
          when 404
            UI.error("❌ Project not found. Please check the project slug.")
            raise "Project not found (404)"
          when 429
            UI.error("❌ Too many requests. Please wait and try again.")
            raise "Rate limit exceeded (429)"
          else
            UI.error("❌ API request failed with status: #{response.code}")
            UI.error("Response: #{response.body}")
            raise "API request failed (#{response.code})"
          end
          
        rescue JSON::ParserError => e
          UI.error("❌ Failed to parse JSON response: #{e.message}")
          raise e
        rescue StandardError => e
          UI.error("❌ Unexpected error: #{e.message}")
          raise e
        end
      end

      def self.description
        "Fetches languages list for a specific project from Weblate via API"
      end

      def self.authors
        ["Flop Butylkin"]
      end

      def self.return_value
        "Returns array of OpenStruct objects with language data (name, code, direction, plural, web_url, url). Empty array if no languages found."
      end

      def self.details
        "This action connects to Weblate API and fetches languages list for a specific project. " \
        "Requires API token for authentication and project slug to identify the project."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :host,
            env_name: "WEBLATE_HOST",
            description: "Weblate host URL (e.g., https://hosted.weblate.org)",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Host cannot be empty") if value.empty?
              UI.user_error!("Host must start with http:// or https://") unless value.start_with?('http://', 'https://')
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :api_token,
            env_name: "WEBLATE_API_TOKEN", 
            description: "API token for Weblate authentication",
            optional: false,
            type: String,
            sensitive: true,
            verify_block: proc do |value|
              UI.user_error!("API token cannot be empty") if value.empty?
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :project_slug,
            env_name: "WEBLATE_PROJECT_SLUG",
            description: "Project slug to fetch languages for",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Project slug cannot be empty") if value.empty?
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :show_details,
            env_name: "WEBLATE_SHOW_DETAILS",
            description: "Show detailed information for each language",
            optional: true,
            type: Boolean,
            default_value: false
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'weblate_projects_languages(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project"
          )',
          'weblate_projects_languages(
            host: "https://hosted.weblate.org", 
            api_token: "your_api_token_here",
            project_slug: "my-project",
            show_details: true
          )',
          'languages = weblate_projects_languages(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project"
          )
          puts "Всего языков: #{languages.count}"'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end 