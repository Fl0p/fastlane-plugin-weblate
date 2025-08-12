require 'fastlane/action'
require_relative '../helper/weblate_helper'
require 'ostruct'

module Fastlane
  module Actions
    class WeblateAddTranslationsAction < Action
      def self.run(params)
        UI.message("🌐 Connecting to Weblate: #{params[:host]}")
        UI.message("📝 Adding translations for project: #{params[:project_slug]}")
        UI.message("📤 Using weblate_file_upload internally...")
        
        # Call weblate_file_upload with the provided parameters
        result = WeblateFileUploadAction.run(params)
        
        # Return result from file upload
        OpenStruct.new(
          success: result,
          message: result ? "Translations added successfully" : "Failed to add translations"
        )
      end

      def self.description
        "Adds new translations to a Weblate project via API"
      end

      def self.authors
        ["Flop Butylkin"]
      end

      def self.return_value
        "Returns OpenStruct object with operation result (success, message, etc.)"
      end

      def self.details
        "This action connects to Weblate API and adds new translations to a project. " \
        "Can add multiple translations at once and supports various translation formats. " \
        "Requires API token for authentication."
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
            description: "Project slug to add translations to",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Project slug cannot be empty") if value.empty?
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :component_slug,
            env_name: "WEBLATE_COMPONENT_SLUG",
            description: "Component slug to add translations to. Supports categorized components (e.g., 'ios/localizable-strings')",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Component slug cannot be empty") if value.empty?
            end
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
          'weblate_add_translations(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "android-strings",
            src_file_path: "./android/values/strings.xml"
          )',
          'weblate_add_translations(
            host: "https://hosted.weblate.org", 
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "ios/localizable-strings",
            src_file_path: "./ios/Base.lproj/Localizable.strings"
          )',
          'src_file_path = "./translations/mobile/common/ios/base/Base.lproj/Localizable.strings"
          
          weblate_add_translations(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "ios/localizable-strings",
            src_file_path: src_file_path
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
