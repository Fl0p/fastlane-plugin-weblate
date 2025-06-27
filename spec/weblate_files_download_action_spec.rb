require 'spec_helper'

describe Fastlane::Actions::WeblateFilesDownloadAction do
  describe '#run' do
    it 'requires host parameter' do
      expect do
        Fastlane::Actions::WeblateFilesDownloadAction.run({})
      end.to raise_error(StandardError)
    end

    it 'requires api_token parameter' do
      expect do
        Fastlane::Actions::WeblateFilesDownloadAction.run({
          host: 'https://hosted.weblate.org'
        })
      end.to raise_error(StandardError)
    end

    it 'requires project_slug parameter' do
      expect do
        Fastlane::Actions::WeblateFilesDownloadAction.run({
          host: 'https://hosted.weblate.org',
          api_token: 'test_token'
        })
      end.to raise_error(StandardError)
    end

    it 'requires component_slug parameter' do
      expect do
        Fastlane::Actions::WeblateFilesDownloadAction.run({
          host: 'https://hosted.weblate.org',
          api_token: 'test_token',
          project_slug: 'test_project'
        })
      end.to raise_error(StandardError)
    end

    it 'validates host URL format' do
      expect do
        Fastlane::Actions::WeblateFilesDownloadAction.run({
          host: 'invalid-url',
          api_token: 'test_token',
          project_slug: 'test_project',
          component_slug: 'test_component'
        })
      end.to raise_error(URI::InvalidURIError)
    end

    it 'validates empty parameters' do
      expect do
        Fastlane::Actions::WeblateFilesDownloadAction.run({
          host: '',
          api_token: 'test_token',
          project_slug: 'test_project',
          component_slug: 'test_component'
        })
      end.to raise_error(URI::InvalidURIError)
    end
  end

  describe 'action properties' do
    it 'has correct description' do
      expect(Fastlane::Actions::WeblateFilesDownloadAction.description).to eq("Downloads component file from Weblate via API")
    end

    it 'has correct authors' do
      expect(Fastlane::Actions::WeblateFilesDownloadAction.authors).to eq(["Flop Butylkin"])
    end

    it 'is supported on all platforms' do
      expect(Fastlane::Actions::WeblateFilesDownloadAction.is_supported?(:ios)).to eq(true)
      expect(Fastlane::Actions::WeblateFilesDownloadAction.is_supported?(:android)).to eq(true)
      expect(Fastlane::Actions::WeblateFilesDownloadAction.is_supported?(:mac)).to eq(true)
    end

    it 'has example code' do
      expect(Fastlane::Actions::WeblateFilesDownloadAction.example_code).not_to be_empty
    end

    it 'has available options' do
      options = Fastlane::Actions::WeblateFilesDownloadAction.available_options
      expect(options).not_to be_empty
      
      option_keys = options.map(&:key)
      expect(option_keys).to include(:host, :api_token, :project_slug, :component_slug, :format, :output_path)
    end
  end
end 