require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class WeblateHelper
      # class methods that you define here become available in your action
      # as `Helper::WeblateHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the weblate plugin helper!")
      end
    end
  end
end
