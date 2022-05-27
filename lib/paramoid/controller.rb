require 'action_controller'

module Paramoid
  module Controller
    extend ActiveSupport::Concern

    def sanitize_params!(&block)
      if block_given?
        sanitized = Paramoid::Base.new
        sanitized.instance_exec(_paramoid_safe_current_user, &block)
        sanitized.sanitize(params)
      else
        base_class_name = self.class.name.demodulize.gsub('Controller', '').singularize

        "#{base_class_name}ParamsSanitizer".safe_constantize&.new(_paramoid_safe_current_user)&.sanitize(params)
      end
    end

    private

    def _paramoid_safe_current_user
      respond_to?(:current_user, true) ? current_user : nil
    end
  end
end

ActionController::Base.include Paramoid::Controller if defined?(ActionController::Base)
