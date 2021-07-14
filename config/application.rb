# frozen_string_literal: true

module BeyondCanvas
  class Application < Rails::Application
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'ALLOWALL'
    }
  end
end
