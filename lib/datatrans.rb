require 'active_support/core_ext/module'

module Datatrans
  InvalidSignatureError = Class.new(StandardError)
end

require 'datatrans/version'
require 'datatrans/common'
require 'datatrans/config'
require 'datatrans/xml/transaction'
require 'datatrans/web/transaction'

begin
  require 'action_view'
  require 'datatrans/web/view_helper'
  ActionView::Base.send(:include, Datatrans::Web::ViewHelper)
rescue LoadError
end
