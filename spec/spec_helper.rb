# frozen_string_literal: true

require 'factory_bot'
require 'faker'
require 'webmock'

require 'nickeltrack'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
    ActiveRecord::Base.establish_connection(
      YAML.load_file(
        File.join(
          File.expand_path('..', __dir__),
          'db',
          'config.yml'
        )
      )['test']
    )
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
