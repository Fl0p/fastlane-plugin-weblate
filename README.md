# weblate plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-weblate)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-weblate`, add it to your project by running:

```bash
fastlane add_plugin weblate
```

## About weblate

Weblate API integration for automating translation workflows in mobile applications.

The plugin allows you to:
- 📋 Fetch project components list
- 📊 View translation statistics
- 🔍 Filter components by projects
- 📄 Support pagination of results

## Setup

To use this plugin you need:

1. **Weblate API token** - get it from your Weblate profile settings
2. **Host URL** - address of your Weblate server

It's recommended to use environment variables:

```bash
export WEBLATE_HOST="https://hosted.weblate.org"
export WEBLATE_API_TOKEN="your_api_token_here"
```

## Usage

### Basic example

```ruby
weblate(
  host: "https://hosted.weblate.org",
  api_token: "your_api_token_here"
)
```

### Get components with details

```ruby
components = weblate(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  show_details: true,
  page_size: 50
)

UI.message("Found components: #{components.count}")
```

### Filter by project

```ruby
weblate(
  host: ENV["WEBLATE_HOST"],
  api_token: ENV["WEBLATE_API_TOKEN"],
  project: "my-mobile-app"
)
```

## Parameters

| Parameter | Required | Description | Environment Variable |
|-----------|----------|-------------|---------------------|
| `host` | ✅ | Weblate host URL | `WEBLATE_HOST` |
| `api_token` | ✅ | API token for authentication | `WEBLATE_API_TOKEN` |
| `project` | ❌ | Project slug for filtering | `WEBLATE_PROJECT` |
| `page` | ❌ | Page number (default: 1) | `WEBLATE_PAGE` |
| `page_size` | ❌ | Items per page (default: 20) | `WEBLATE_PAGE_SIZE` |
| `show_details` | ❌ | Show component details | `WEBLATE_SHOW_DETAILS` |

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
