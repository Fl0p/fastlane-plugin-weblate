# weblate plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-weblate)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-weblate`, add it to your project by running:

```bash
fastlane add_plugin weblate
```

## About weblate

Weblate API integration for automating translation workflows in mobile applications.

The plugin provides four main actions:
- 📋 **weblate** - Fetch projects list with detailed statistics
- 🌍 **weblate_projects_languages** - Get languages for a specific project
- 📄 **weblate_files_download** - Download translation files from components
- 📤 **weblate_file_upload** - Upload translation files to components

## Setup

To use this plugin you need:

1. **Weblate API token** - get it from your Weblate profile settings
2. **Host URL** - address of your Weblate server

It's recommended to use environment variables:

```bash
export WEBLATE_HOST="https://hosted.weblate.org"
export WEBLATE_API_TOKEN="your_api_token_here"
```

## Actions

### 1. weblate - Fetch Projects List

Fetches projects list from Weblate with optional detailed statistics.

#### Parameters

| Parameter | Required | Description | Environment Variable |
|-----------|----------|-------------|---------------------|
| `host` | ✅ | Weblate host URL | `WEBLATE_HOST` |
| `api_token` | ✅ | API token for authentication | `WEBLATE_API_TOKEN` |
| `page` | ❌ | Page number (default: 1) | `WEBLATE_PAGE` |
| `page_size` | ❌ | Items per page (default: 20, max: 200) | `WEBLATE_PAGE_SIZE` |
| `show_details` | ❌ | Show detailed statistics | `WEBLATE_SHOW_DETAILS` |

#### Examples

```ruby
# Basic usage
weblate(
  host: "https://hosted.weblate.org",
  api_token: "your_api_token_here"
)

# With detailed statistics
weblate(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  show_details: true
)

# With pagination
projects = weblate(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  page_size: 50
)
UI.message("Found projects: #{projects.count}")
```

### 2. weblate_projects_languages - Get Project Languages

Fetches the list of languages available for a specific project.

#### Parameters

| Parameter | Required | Description | Environment Variable |
|-----------|----------|-------------|---------------------|
| `host` | ✅ | Weblate host URL | `WEBLATE_HOST` |
| `api_token` | ✅ | API token for authentication | `WEBLATE_API_TOKEN` |
| `project_slug` | ✅ | Project slug to fetch languages for | `WEBLATE_PROJECT_SLUG` |
| `show_details` | ❌ | Show detailed information | `WEBLATE_SHOW_DETAILS` |

#### Examples

```ruby
# Basic usage
weblate_projects_languages(
  host: "https://hosted.weblate.org",
  api_token: "your_api_token_here",
  project_slug: "my-mobile-app"
)

# With detailed information
weblate_projects_languages(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  project_slug: "my-mobile-app",
  show_details: true
)

# Store results for processing
languages = weblate_projects_languages(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  project_slug: "my-mobile-app"
)
UI.message("Total languages: #{languages.count}")
```

### 3. weblate_files_download - Download Translation Files

Downloads translation files from Weblate components. Supports various formats and categorized components.

#### Parameters

| Parameter | Required | Description | Environment Variable |
|-----------|----------|-------------|---------------------|
| `host` | ✅ | Weblate host URL | `WEBLATE_HOST` |
| `api_token` | ✅ | API token for authentication | `WEBLATE_API_TOKEN` |
| `project_slug` | ✅ | Project slug | `WEBLATE_PROJECT_SLUG` |
| `component_slug` | ✅ | Component slug (supports categories like `ios/localizable-strings`) | `WEBLATE_COMPONENT_SLUG` |
| `format` | ❌ | File format (po, json, xliff, etc.) | `WEBLATE_FILE_FORMAT` |
| `output_path` | ❌ | Path to save the file | `WEBLATE_OUTPUT_PATH` |

#### Examples

```ruby
# Basic download (returns content)
file_content = weblate_files_download(
  host: "https://hosted.weblate.org",
  api_token: "your_api_token_here",
  project_slug: "my-project",
  component_slug: "android-strings"
)

# Download with specific format and save to file
weblate_files_download(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  project_slug: "my-project",
  component_slug: "ios-localizable",
  format: "json",
  output_path: "./translations/strings.json"
)

# Download from categorized component
weblate_files_download(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  project_slug: "my-project",
  component_slug: "ios/localizable-strings",
  output_path: "./translations/ios_strings.po"
)
```

### 4. weblate_file_upload - Upload Translation Files

Uploads translation files to Weblate components for a specific language. This is useful for updating translations with new strings or content.

#### Parameters

| Parameter | Required | Description | Environment Variable |
|-----------|----------|-------------|---------------------|
| `host` | ✅ | Weblate host URL | `WEBLATE_HOST` |
| `api_token` | ✅ | API token for authentication | `WEBLATE_API_TOKEN` |
| `project_slug` | ✅ | Project slug | `WEBLATE_PROJECT_SLUG` |
| `component_slug` | ✅ | Component slug (supports categories like `ios/localizable-strings`) | `WEBLATE_COMPONENT_SLUG` |
| `src_file_path` | ✅ | Path to the source file to upload | `WEBLATE_SRC_FILE_PATH` |
| `language` | ❌ | Language code (default: `en_devel`) | `WEBLATE_LANGUAGE` |
| `method` | ❌ | Upload method: `translate`, `approve`, `suggest`, `fuzzy`, `replace`, `source`, `add` (default: `translate`) | `WEBLATE_UPLOAD_METHOD` |
| `conflicts` | ❌ | Conflict resolution: `ignore`, `replace-translated`, `replace-approved` (default: `ignore`) | `WEBLATE_CONFLICTS` |
| `email` | ❌ | Author email (defaults to git user.email) | `WEBLATE_AUTHOR_EMAIL` |
| `author` | ❌ | Author name (defaults to git user.name) | `WEBLATE_AUTHOR_NAME` |
| `fuzzy` | ❌ | Fuzzy strings processing: `process`, `approve` | `WEBLATE_FUZZY` |

#### Examples

```ruby
# Basic upload (en_devel language by default)
weblate_file_upload(
  host: "https://hosted.weblate.org",
  api_token: "your_api_token_here",
  project_slug: "my-project",
  component_slug: "android-strings",
  src_file_path: "./android/values/strings.xml"
)

# Upload with specific language and method
weblate_file_upload(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  project_slug: "my-project",
  component_slug: "ios-localizable",
  language: "es",
  method: "replace",
  conflicts: "replace-translated",
  src_file_path: "./ios/es.lproj/Localizable.strings"
)

# Upload to categorized component with custom author info
weblate_file_upload(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  project_slug: "my-project",
  component_slug: "ios/localizable-strings",
  language: "en_devel",
  author: "John Doe",
  email: "john@example.com",
  fuzzy: "process",
  src_file_path: "./translations/Base.lproj/Localizable.strings"
)
```

## Complete Workflow Example

Here's a complete example showing how to use all four actions together:

```ruby
# 1. Get all projects
projects = weblate(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  show_details: true
)

# 2. For each project, get languages
projects.results.each do |project|
  UI.message("Processing project: #{project.name}")
  
  languages = weblate_projects_languages(
    host: ENV["WEBLATE_HOST"],
    api_token: ENV["WEBLATE_API_TOKEN"],
    project_slug: project.slug
  )
  
  UI.message("Available languages: #{languages.map(&:code).join(', ')}")
  
  # 3. Download files for specific components
  weblate_files_download(
    host: ENV["WEBLATE_HOST"],
    api_token: ENV["WEBLATE_API_TOKEN"],
    project_slug: project.slug,
    component_slug: "mobile-strings",
    format: "json",
    output_path: "./translations/#{project.slug}_strings.json"
  )
  
  # 4. Upload updated files back to Weblate
  weblate_file_upload(
    host: ENV["WEBLATE_HOST"],
    api_token: ENV["WEBLATE_API_TOKEN"],
    project_slug: project.slug,
    component_slug: "mobile-strings",
    language: "en_devel",
    src_file_path: "./source/#{project.slug}_strings.json"
  )
end
```

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
