require 'rubygems'
require 'bundler/setup'

require 'active_support'
require 'datatrans'

RSpec.configure do |config|
  config.before(:each) do
    Datatrans.configure do |config|
      config.merchant_id = '1100000000'
      config.sign_key = 'd777c17ba2010282c2d2350a68b441ca07a799d294bfaa630b7c8442207c0b69703cc55775b0ca5a4e455b818a9bb10a43669c0c20ce31f4a43f10e0cabb9525'
      config.environment = :development
    end
  end
end
