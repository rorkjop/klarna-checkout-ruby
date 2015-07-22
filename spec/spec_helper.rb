require 'klarna/checkout'

require 'webmock/rspec'
require 'vcr'
require 'rspec/its'

# require 'shoulda/matchers'

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path("../fixtures/vcr_cassettes", __FILE__)
  c.hook_into :webmock # or :fakeweb
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered                = true

  config.filter_run :focus => true
  config.mock_with  :rspec

  # config.order = "random"
end

Dir[File.expand_path("../shared/**/*.rb",  __FILE__)].each { |f| require f }
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }
