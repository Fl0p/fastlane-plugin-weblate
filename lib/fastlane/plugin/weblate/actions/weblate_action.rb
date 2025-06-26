require 'fastlane/action'
require_relative '../helper/weblate_helper'
require 'weblate'

module Fastlane
  module Actions
    class WeblateAction < Action
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
            
            # Parameters for projects list request
            opts = {}
            opts[:page] = params[:page] if params[:page]
            opts[:page_size] = params[:page_size] if params[:page_size]
            
            UI.message("🌐 Connecting to Weblate: #{params[:host]}")
            UI.message("📋 Fetching projects list...")
            
            # Execute request
            result = api_instance.projects_list(opts)
            
            UI.success("✅ Successfully fetched projects list!")
            UI.message("📊 Found projects: #{result.count}")
            
            if params[:show_details]
              UI.message("\n📋 Project details:")
              result.results.each_with_index do |project, index|
                UI.message("#{index + 1}. #{project.name} (#{project.slug})")
                UI.message("   URL: #{project.web_url}")
                # Note: stats may not be available in the project object
                UI.message("")
              end
            end
            
            # Return result for further use
            result
            
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
        "Fetches projects list from Weblate via API"
      end

      def self.authors
        ["Flop Butylkin"]
      end

              def self.return_value
          "Returns PaginatedProjectList object with Weblate projects data"
        end

              def self.details
          "This action connects to Weblate API and fetches projects list. " \
          "Supports pagination. Requires API token for authentication."
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
            key: :page,
            env_name: "WEBLATE_PAGE",
            description: "Page number for pagination",
            optional: true,
            type: Integer,
            default_value: 1
          ),
          FastlaneCore::ConfigItem.new(
            key: :page_size,
            env_name: "WEBLATE_PAGE_SIZE",
            description: "Number of items per page",
            optional: true,
            type: Integer,
            default_value: 20,
            verify_block: proc do |value|
              UI.user_error!("page_size must be greater than 0") if value <= 0
              UI.user_error!("page_size cannot be greater than 200") if value > 200
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :show_details,
            env_name: "WEBLATE_SHOW_DETAILS",
            description: "Show detailed information for each project",
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
          'weblate(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here"
          )',
          'weblate(
            host: "https://hosted.weblate.org", 
            api_token: "your_api_token_here",
            show_details: true
          )',
          'projects = weblate(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            page_size: 50
          )
          puts "Всего проектов: #{projects.count}"'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
