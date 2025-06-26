require 'spec_helper'

describe Fastlane::Actions::WeblateAction do
  describe '#run' do
    let(:valid_params) do
      {
        host: 'https://hosted.weblate.org',
        api_token: 'test_token_123'
      }
    end

    let(:mock_api_instance) { double('Weblate::ComponentsApi') }
    let(:mock_result) do
      double('result', 
        count: 5,
        results: [
          double('component', 
            name: 'Test Component', 
            slug: 'test-component',
            project: double('project', name: 'Test Project'),
            web_url: 'https://example.com/component',
            statistics: { 'translated' => 80, 'total' => 100 }
          )
        ]
      )
    end

    before do
      allow(Weblate).to receive(:configure)
      allow(Weblate::ComponentsApi).to receive(:new).and_return(mock_api_instance)
      allow(mock_api_instance).to receive(:components_list).and_return(mock_result)
    end

    it 'runs successfully with basic parameters' do
      expect(Fastlane::UI).to receive(:message).with("🌐 Connecting to Weblate: #{valid_params[:host]}")
      expect(Fastlane::UI).to receive(:message).with("📋 Fetching components list...")
      expect(Fastlane::UI).to receive(:success).with("✅ Successfully fetched components list!")
      expect(Fastlane::UI).to receive(:message).with("📊 Found components: 5")

      result = Fastlane::Actions::WeblateAction.run(valid_params)
      expect(result).to eq(mock_result)
    end

    it 'shows component details when show_details=true' do
      params = valid_params.merge(show_details: true)
      
      expect(Fastlane::UI).to receive(:message).with("\n📋 Component details:")
      expect(Fastlane::UI).to receive(:message).with("1. Test Component (test-component)")
      expect(Fastlane::UI).to receive(:message).with("   Project: Test Project")
      expect(Fastlane::UI).to receive(:message).with("   URL: https://example.com/component")
      expect(Fastlane::UI).to receive(:message).with(/   Statistics:/)
      expect(Fastlane::UI).to receive(:message).with("")

      Fastlane::Actions::WeblateAction.run(params)
    end

    it 'passes pagination parameters to API' do
      params = valid_params.merge(page: 2, page_size: 50, project: 'my-project')
      
      expect(mock_api_instance).to receive(:components_list).with({
        page: 2,
        page_size: 50,
        project: 'my-project'
      }).and_return(mock_result)

      Fastlane::Actions::WeblateAction.run(params)
    end

    it 'handles API errors' do
      api_error = Weblate::ApiError.new('API Error', 404, {})
      allow(mock_api_instance).to receive(:components_list).and_raise(api_error)

      expect(Fastlane::UI).to receive(:error).with("❌ Weblate API error: API Error")
      expect(Fastlane::UI).to receive(:error).with("Error code: 404")

      expect { Fastlane::Actions::WeblateAction.run(valid_params) }.to raise_error(Weblate::ApiError)
    end

    it 'validates required parameters' do
      expect { Fastlane::Actions::WeblateAction.run({}) }.to raise_error
    end
  end

  describe 'parameters' do
    it 'has correct required parameters' do
      options = Fastlane::Actions::WeblateAction.available_options
      
      host_option = options.find { |opt| opt.key == :host }
      expect(host_option.optional).to be false
      
      token_option = options.find { |opt| opt.key == :api_token }
      expect(token_option.optional).to be false
      expect(token_option.sensitive).to be true
    end

    it 'has correct optional parameters' do
      options = Fastlane::Actions::WeblateAction.available_options
      
      optional_keys = [:project, :page, :page_size, :show_details]
      optional_keys.each do |key|
        option = options.find { |opt| opt.key == key }
        expect(option.optional).to be true
      end
    end
  end
end
