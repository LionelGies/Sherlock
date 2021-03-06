# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.after(:each) do
    # clean up any tmp user files
    pics_path = Rails.root.to_s + '/' + APP_CONFIG['files_path']
    Dir[pics_path + '*'].each { |f| FileUtils.rm_rf(f) }
    
    vol1_path = File.join(Rails.root, 'tmp', 'mnt', 'vol1')
    Dir[File.join(vol1_path, '*')].each do |f|      
      #FileUtils.rm_rf(f)
    end
    
    vol2_path = File.join(Rails.root, 'tmp', 'mnt', 'vol2')
    Dir[File.join(vol2_path, '*')].each do |f|       
      #FileUtils.rm_rf(f)      
    end
    
  end
  
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
end
