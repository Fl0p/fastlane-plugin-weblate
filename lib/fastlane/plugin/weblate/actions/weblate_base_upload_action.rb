require 'fastlane/action'
require_relative '../helper/weblate_helper'
require 'net/http'
require 'uri'
require 'json'

module Fastlane
  module Actions
    class WeblateBaseUploadAction < Action
      def self.run(params)
        # Build API endpoint URL
        base_url = Helper::WeblateHelper.build_api_base_url(params[:host])
        # Handle categorized components by double URL-encoding the slash (/ -> %252F)
        encoded_component_slug = params[:component_slug].gsub('/', '%252F')
        api_url = "#{base_url}/components/#{params[:project_slug]}/#{encoded_component_slug}/file/"
        
        UI.message("🌐 Connecting to Weblate: #{params[:host]}")
        UI.message("📤 Uploading file for project: #{params[:project_slug]}, component: #{params[:component_slug]}")
        
        begin
          # TODO: Implement upload logic here
          UI.message("📁 Source file: #{params[:src_file_path]}")
          UI.message("📡 API URL: #{api_url}")
          
          # Placeholder for upload implementation
          UI.success("✅ Upload action prepared (implementation pending)")
          
          # Return success status for now
          true
          
        rescue StandardError => e
          UI.error("❌ Failed to upload file: #{e.message}")
          raise e
        end
      end

      def self.description
        "Uploads base file to Weblate component via API"
      end

      def self.authors
        ["Flop Butylkin"]
      end

      def self.return_value
        "Returns true if upload was successful"
      end

      def self.details
        "This action connects to Weblate API and uploads a base file for a specific component. " \
        "Requires API token for authentication, project slug, component slug, and source file path. " \
        "Supports different file formats and can handle categorized components (e.g., 'ios/localizable-strings') with proper URL encoding."
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
            description: "Project slug for the component",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Project slug cannot be empty") if value.empty?
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :component_slug,
            env_name: "WEBLATE_COMPONENT_SLUG",
            description: "Component slug to upload file to. Supports categorized components (e.g., 'ios/localizable-strings')",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Component slug cannot be empty") if value.empty?
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :format,
            env_name: "WEBLATE_FILE_FORMAT",
            description: "File format to upload (e.g., po, json, xliff). If not specified, auto-detects from file extension",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :src_file_path,
            env_name: "WEBLATE_SRC_FILE_PATH",
            description: "Path to the source file to upload to Weblate",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Source file path cannot be empty") if value.empty?
              UI.user_error!("Source file does not exist: #{value}") unless File.exist?(value)
            end
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'weblate_base_upload(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "android-strings",
            src_file_path: "./translations/strings.po"
          )',
          'weblate_base_upload(
            host: "https://hosted.weblate.org", 
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "ios-localizable",
            format: "json",
            src_file_path: "./translations/strings.json"
          )',
          'weblate_base_upload(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "ios/localizable-strings",
            src_file_path: "./translations/ios_strings.po"
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end 