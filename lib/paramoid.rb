# frozen_string_literal: true

module Paramoid
  extend ActiveSupport::Autoload

  autoload :Object
  autoload :List
  autoload :Base
  # autoload :Controller
end

require 'paramoid/controller'
