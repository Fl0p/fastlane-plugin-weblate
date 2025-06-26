require 'fastlane/action'
require_relative '../helper/weblate_helper'
require 'weblate'

module Fastlane
  module Actions
    class WeblateProjectsLanguagesAction < Action
      def self.run(params)
          # Parse URL components
          uri = URI(params[:host])
          
          # Configure API client
          ::Weblate.configure do |config|
            config.scheme = uri.scheme
            config.host = uri.host
            config.base_path = uri.path.empty? ? '/api' : uri.path
            config.api_key['Authorization'] = params[:api_token]
            config.api_key_prefix['Authorization'] = 'Token'
          end

          begin
            # Create API client instance
            api_instance = ::Weblate::ProjectsApi.new
            
            UI.message("🌐 Connecting to Weblate: #{params[:host]}")
            UI.message("🔍 Fetching languages for project: #{params[:project_slug]}")
            
            # Execute request
            result = api_instance.projects_languages_retrieve(params[:project_slug])
            
            UI.success("✅ Successfully fetched project languages!")
            puts "result: #{result.to_json}"
            # Handle different possible response structures
            languages = if result.respond_to?(:results)
                         result.results || []
                       elsif result.is_a?(Array)
                         result
                       elsif result.respond_to?(:languages)
                         result.languages || []
                       else
                         []
                       end
            
            UI.message("🌍 Found languages: #{languages.count}")
            
            if params[:show_details] && !languages.empty?
              UI.message("\n🌍 Language details:")
              languages.each_with_index do |language, index|
                UI.message("#{index + 1}. #{language.name} (#{language.code})")
                if language.respond_to?(:direction)
                  UI.message("   Direction: #{language.direction}")
                end
                if language.respond_to?(:plural)
                  UI.message("   Plural count: #{language.plural}")
                end
                UI.message("")
              end
            elsif params[:show_details] && languages.empty?
              UI.message("📝 No languages found for this project")
            end
            
            # Return processed languages for further use
            languages
            
          rescue ::Weblate::ApiError => e
            UI.error("❌ Weblate API error: #{e.message}")
            UI.error("Error code: #{e.code}")
            UI.error("Response headers: #{e.response_headers}")
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
        "Returns array of Language objects with project languages data (empty array if no languages found)"
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