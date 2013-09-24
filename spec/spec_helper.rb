require 'rubygems'
require 'bundler/setup'

require 'active_support'
require 'datatrans'

RSpec.configure do |config|
  config.filter_run :focus => true
  config.filter_run_excluding :skip => true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    @datatrans = Datatrans::Config.new(
      :merchant_id => '1100000000',
      :sign_key => 'd777c17ba2010282c2d2350a68b441ca07a799d294bfaa630b7c8442207c0b69703cc55775b0ca5a4e455b818a9bb10a43669c0c20ce31f4a43f10e0cabb9525',
      :environment => :development
    )
  end
end
