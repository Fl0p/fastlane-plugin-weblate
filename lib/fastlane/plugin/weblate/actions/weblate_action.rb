require 'fastlane/action'
require_relative '../helper/weblate_helper'
require 'ostruct'

module Fastlane
  module Actions
    class WeblateAction < Action
      def self.run(params)
        # Build API endpoint URL with pagination parameters
        base_url = Helper::WeblateHelper.build_api_base_url(params[:host])
        api_url = "#{base_url}/projects/"
        query_params = []
        query_params << "page=#{params[:page]}" if params[:page]
        query_params << "page_size=#{params[:page_size]}" if params[:page_size]
        api_url += "?#{query_params.join('&')}" unless query_params.empty?
        
        UI.message("🌐 Connecting to Weblate: #{params[:host]}")
        UI.message("📋 Fetching projects list...")
        
        # Use helper method to make API request
        result = Helper::WeblateHelper.make_api_request(api_url, params[:api_token], "✅ Successfully fetched projects list!")
        
        # Handle different possible response structures
        projects_data = if result.is_a?(Hash) && result['results']
                         result['results'] || []
                       elsif result.is_a?(Array)
                         result
                       else
                         []
                       end
        
        # Convert hash data to objects with attribute access
        projects = projects_data.map do |project_data|
          OpenStruct.new(
            name: project_data['name'] || 'Unknown',
            slug: project_data['slug'] || 'unknown',
            web_url: project_data['web_url'],
            url: project_data['url'],
            source_language: project_data['source_language'],
            languages_count: project_data['languages_count'],
            components_count: project_data['components_count']
          )
        end
        
        # Create result object similar to the original API response
        result_obj = OpenStruct.new(
          count: result['count'] || projects.count,
          next: result['next'],
          previous: result['previous'],
          results: projects
        )
        
        UI.message("📊 Found projects: #{projects.count}")
        
        if params[:show_details] && !projects.empty?
          UI.message("\n📋 Project details:")
          projects.each_with_index do |project, index|
            UI.message("#{index + 1}. #{project.name} (#{project.slug})")
            UI.message("   URL: #{project.web_url}") if project.web_url
            UI.message("   Languages: #{project.languages_count}") if project.languages_count
            UI.message("   Components: #{project.components_count}") if project.components_count
            UI.message("")
          end
        elsif params[:show_details] && projects.empty?
          UI.message("📝 No projects found")
        end
        
        # Return result for further use
        result_obj
      end

      def self.description
        "Fetches projects list from Weblate via API"
      end

      def self.authors
        ["Flop Butylkin"]
      end

      def self.return_value
        "Returns OpenStruct object with projects data (count, next, previous, results). Results contain array of project objects with name, slug, web_url, etc."
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
