require 'action_controller'
require 'rspec'
require 'paramoid'

I18n.enforce_available_locales = false
RSpec::Expectations.configuration.warn_about_potential_false_positives = false

Dir[File.expand_path('support/*.rb', __dir__)].each { |f| require f }

RSpec.configure do |config|
end
