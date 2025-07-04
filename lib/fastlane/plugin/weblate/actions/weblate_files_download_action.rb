require 'fastlane/action'
require_relative '../helper/weblate_helper'
require 'net/http'
require 'uri'
require 'json'

module Fastlane
  module Actions
    class WeblateFilesDownloadAction < Action
      def self.run(params)
        # Build API endpoint URL
        base_url = Helper::WeblateHelper.build_api_base_url(params[:host])
        # Handle categorized components by double URL-encoding the slash (/ -> %252F)
        encoded_component_slug = params[:component_slug].gsub('/', '%252F')
        api_url = "#{base_url}/components/#{params[:project_slug]}/#{encoded_component_slug}/file/"
        
        UI.message("🌐 Connecting to Weblate: #{params[:host]}")
        UI.message("📦 Downloading file for project: #{params[:project_slug]}, component: #{params[:component_slug]}")
        
        begin
          uri = URI(api_url)
          http = Helper::WeblateHelper.create_http_client(uri)
          request = Helper::WeblateHelper.create_request(uri, params[:api_token])
          
          # Add format parameter if specified
          if params[:format]
            uri.query = "format=#{params[:format]}"
            request = Helper::WeblateHelper.create_request(uri, params[:api_token])
          end
          
          UI.message("📡 API URL: #{uri}")
          
          response = http.request(request)
          Helper::WeblateHelper.handle_response_errors(response)
          
          # For file downloads, we expect binary content, not JSON
          file_content = response.body
          
          # Save file if output_path is specified
          if params[:output_path]
            File.write(params[:output_path], file_content)
            UI.success("✅ File successfully downloaded to: #{params[:output_path]}")
            
            # Show file info
            file_size = File.size(params[:output_path])
            UI.message("📁 File size: #{file_size} bytes")
          else
            UI.success("✅ File content retrieved successfully!")
            UI.message("📄 Content length: #{file_content.length} bytes")
          end
          
          # Return file content for further processing
          file_content
          
        rescue StandardError => e
          UI.error("❌ Failed to download file: #{e.message}")
          raise e
        end
      end

      def self.description
        "Downloads component file from Weblate via API"
      end

      def self.authors
        ["Flop Butylkin"]
      end

      def self.return_value
        "Returns the file content as string. If output_path is specified, also saves the file to disk."
      end

      def self.details
        "This action connects to Weblate API and downloads a file for a specific component. " \
        "Requires API token for authentication, project slug, and component slug to identify the file. " \
        "Supports different file formats and can save the file to a specified path. " \
        "Automatically handles categorized components (e.g., 'ios/localizable-strings') with proper URL encoding."
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
            description: "Component slug to download file from. Supports categorized components (e.g., 'ios/localizable-strings')",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Component slug cannot be empty") if value.empty?
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :format,
            env_name: "WEBLATE_FILE_FORMAT",
            description: "File format to download. Defaults to 'zip' if not specified. " \
                        "Supported formats: 'zip' (original format archive) and 'zip:CONVERSION' " \
                        "where CONVERSION is one of the converters: " \
                        "po, xliff, xliff11, tbx, tmx, mo, csv, xlsx, json, json-nested, aresource, strings. " \
                        "For individual translation files, you can also use: po, json, xliff, etc. " \
                        "Examples: 'zip:po' for gettext PO archive, 'zip:xliff' for XLIFF archive, 'json' for individual JSON file",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :output_path,
            env_name: "WEBLATE_OUTPUT_PATH",
            description: "Path where to save the downloaded file. If not specified, only returns content",
            optional: true,
            type: String
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'weblate_files_download(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "android-strings"
          )',
          '# Download as default ZIP format (original format archive)
          weblate_files_download(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "mobile-app",
            format: "zip",
            output_path: "./translations/original_archive.zip"
          )',
          '# Download as ZIP archive with XLIFF conversion
          weblate_files_download(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "web-app",
            format: "zip:xliff",
            output_path: "./translations/xliff_archive.zip"
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end 