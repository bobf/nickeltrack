# frozen_string_literal: true

module Nickeltrack
  module Secrets
    def secrets
      return env_secrets if env_secrets?

      @secrets ||= YAML.load_file(
        File.join(File.expand_path('../..', __dir__), 'config', 'secrets.yml')
      )
    end

    def env_secrets
      {
        'last_fm' => {
          'username' => ENV['NICKELTRACK_LAST_FM_USERNAME'],
          'api_key' => ENV['NICKELTRACK_LAST_API_FM_TOKEN']
        }
      }
    end

    def env_secrets?
      return false if ENV['NICKELTRACK_LAST_FM_USERNAME'].nil?
      return false if ENV['NICKELTRACK_LAST_API_FM_TOKEN'].nil?

      true
    end
  end
end
