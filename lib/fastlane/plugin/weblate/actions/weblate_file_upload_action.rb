require 'fastlane/action'
require_relative '../helper/weblate_helper'
require 'net/http'
require 'uri'
require 'json'

module Fastlane
  module Actions
    class WeblateFileUploadAction < Action
      def self.run(params)
        # Build API endpoint URL for translations
        base_url = Helper::WeblateHelper.build_api_base_url(params[:host])
        # Handle categorized components by double URL-encoding the slash (/ -> %252F)
        encoded_component_slug = params[:component_slug].gsub('/', '%252F')
        api_url = "#{base_url}/translations/#{params[:project_slug]}/#{encoded_component_slug}/#{params[:language]}/file/"
        
        UI.message("🌐 Connecting to Weblate: #{params[:host]}")
        UI.message("📤 Uploading file for project: #{params[:project_slug]}, component: #{params[:component_slug]}, language: #{params[:language]}")
        
        begin
          # Prepare the file for upload
          file_path = params[:src_file_path]
          UI.message("📁 Source file: #{file_path}")
          UI.message("📡 API URL: #{api_url}")
          
          # Create URI and HTTP request
          uri = URI.parse(api_url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme == 'https'
          
          # Create multipart form request
          request = Net::HTTP::Post.new(uri.path)
          request['Authorization'] = "Token #{params[:api_token]}"
          
          # Read file content
          file_content = File.read(file_path)
          filename = File.basename(file_path)
          
          # Build multipart form data
          boundary = '----formdata-' + rand(1000000).to_s
          request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
          
          post_body = []
          
          # Add file field
          post_body << "--#{boundary}\r\n"
          post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"\r\n"
          post_body << "Content-Type: application/octet-stream\r\n\r\n"
          post_body << file_content
          post_body << "\r\n"
          
          # Add method field (for overriding existing translations)
          if params[:method]
            post_body << "--#{boundary}\r\n"
            post_body << "Content-Disposition: form-data; name=\"method\"\r\n\r\n"
            post_body << params[:method]
            post_body << "\r\n"
          end
          
          # Add conflicts field
          if params[:conflicts]
            post_body << "--#{boundary}\r\n"
            post_body << "Content-Disposition: form-data; name=\"conflicts\"\r\n\r\n"
            post_body << params[:conflicts]
            post_body << "\r\n"
          end
          
          # Add author email field
          email_value = params[:email].is_a?(Proc) ? params[:email].call : params[:email]
          if email_value && !email_value.empty?
            post_body << "--#{boundary}\r\n"
            post_body << "Content-Disposition: form-data; name=\"email\"\r\n\r\n"
            post_body << email_value
            post_body << "\r\n"
            UI.message("📧 Author email: #{email_value}")
          end
          
          # Add author name field
          author_value = params[:author].is_a?(Proc) ? params[:author].call : params[:author]
          if author_value && !author_value.empty?
            post_body << "--#{boundary}\r\n"
            post_body << "Content-Disposition: form-data; name=\"author\"\r\n\r\n"
            post_body << author_value
            post_body << "\r\n"
            UI.message("👤 Author name: #{author_value}")
          end
          
          # Add fuzzy field
          if params[:fuzzy]
            post_body << "--#{boundary}\r\n"
            post_body << "Content-Disposition: form-data; name=\"fuzzy\"\r\n\r\n"
            post_body << params[:fuzzy]
            post_body << "\r\n"
          end
          
          post_body << "--#{boundary}--\r\n"
          
          request.body = post_body.join
          
          UI.message("🚀 Sending upload request...")
          
          # Make the request
          response = http.request(request)
          
          case response.code.to_i
          when 200, 201
            result = JSON.parse(response.body) rescue {}
            UI.success("✅ File uploaded successfully!")
            UI.message("📊 Upload result: #{result}")
            true
          when 400
            error_details = JSON.parse(response.body) rescue { 'error' => 'Bad request' }
            UI.error("❌ Bad request (400): #{error_details}")
            false
          when 401
            UI.error("❌ Authentication failed (401): Invalid API token")
            false
          when 403
            UI.error("❌ Access forbidden (403): Check project/component permissions")
            false
          when 404
            UI.error("❌ Not found (404): Project, component, or language not found")
            false
          when 429
            UI.error("❌ Rate limited (429): Too many requests")
            false
          else
            UI.error("❌ Upload failed with status #{response.code}: #{response.body}")
            false
          end
          
        rescue StandardError => e
          UI.error("❌ Failed to upload file: #{e.message}")
          UI.error("🔍 Stack trace: #{e.backtrace.join("\n")}")
          raise e
        end
      end

      def self.description
        "Uploads translation file to Weblate component via API"
      end

      def self.authors
        ["Flop Butylkin"]
      end

      def self.return_value
        "Returns true if upload was successful, false otherwise"
      end

      def self.details
        "This action connects to Weblate API and uploads a translation file for a specific component and language. " \
        "Uses the POST /api/translations/{project}/{component}/{language}/file/ endpoint. " \
        "Requires API token for authentication, project slug, component slug, language code, and source file path. " \
        "Can handle categorized components (e.g., 'ios/localizable-strings') with proper URL encoding."
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
            key: :language,
            env_name: "WEBLATE_LANGUAGE",
            description: "Language code for the translation (e.g., 'en', 'es', 'fr')",
            optional: true,
            type: String,
            default_value: "en_devel",
          ),

          FastlaneCore::ConfigItem.new(
            key: :method,
            env_name: "WEBLATE_UPLOAD_METHOD",
            description: "Upload method: 'translate' (default), 'approve', 'suggest', 'fuzzy', 'replace', 'source', 'add'",
            optional: true,
            type: String,
            default_value: "translate"
          ),
          FastlaneCore::ConfigItem.new(
            key: :conflicts,
            env_name: "WEBLATE_CONFLICTS",
            description: "How to deal with conflicts: 'ignore' (default), 'replace-translated', 'replace-approved'",
            optional: true,
            type: String,
            default_value: "ignore"
          ),
          FastlaneCore::ConfigItem.new(
            key: :email,
            env_name: "WEBLATE_AUTHOR_EMAIL",
            description: "Author e-mail for the upload (defaults to git user.email)",
            optional: true,
            type: String,
            default_value_dynamic: true,
            default_value: proc do
              begin
                email = `git config user.email`.strip
                email.empty? ? nil : email
              rescue
                nil
              end
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :author,
            env_name: "WEBLATE_AUTHOR_NAME",
            description: "Author name for the upload (defaults to git user.name)",
            optional: true,
            type: String,
            default_value_dynamic: true,
            default_value: proc do
              begin
                name = `git config user.name`.strip
                name.empty? ? nil : name
              rescue
                nil
              end
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :fuzzy,
            env_name: "WEBLATE_FUZZY",
            description: "Fuzzy (marked for edit) strings processing: nil (default), 'process', 'approve'",
            optional: true,
            type: String,
            default_value: nil
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
          'weblate_file_upload(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "android-strings",
            language: "en_devel",
            src_file_path: "./android/values/strings.xml"
          )',
          'weblate_file_upload(
            host: "https://hosted.weblate.org", 
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "ios-localizable",
            language: "es",
            method: "replace",
            conflicts: "replace-translated",
            author: "John Doe",
            email: "john@example.com",
            fuzzy: "process",
            src_file_path: "./ios/Localizable.strings"
          )',
          'weblate_file_upload(
            host: "https://hosted.weblate.org",
            api_token: "your_api_token_here",
            project_slug: "my-project",
            component_slug: "some-component",
            language: "fr",
            src_file_path: "./translations/some_strings.po"
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end 