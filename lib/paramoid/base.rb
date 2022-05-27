module Paramoid
  class Base
    # @param [ActionController::Parameters] params
    def sanitize(params)
      params = params.permit(*permitted_params)
      scalar_params.transform_params!(params)
      params = default_params.merge(params)
      ensure_required_params!(params)
    end

    protected

    # @param [Symbol] name
    # @param [Symbol] as
    # @param [Lambda | NilClass] transformer
    def group!(name, as: nil, transformer: nil)
      key = as || name
      data = Object.new(name, key, nested: List.new, transformer: transformer)
      context << data
      return unless block_given?

      old_context = context
      @context = data
      yield
      @context = old_context
    end

    alias list! group!
    alias array! group!

    # @param [Array<Symbol>] names
    def params!(*names, required: false)
      names.each { |name| param! name, required: required }
    end

    def param!(name, as: nil, transformer: nil, default: nil, required: false)
      key = as || name
      data = Object.new(name, key, nested: nil, default: default, transformer: transformer, required: required)
      context << data
    end

    def default!(name, value)
      data = Object.new(name, name, nested: nil, default: value)
      context << data
    end

    private

    def context
      @context ||= scalar_params
    end

    def default_params
      scalar_params.to_defaults
      # @default_params ||= {}.with_indifferent_access
    end

    def scalar_params
      @scalar_params ||= List.new
    end

    def ensure_required_params!(params)
      scalar_params.ensure_required_params!(params)
      params
    end

    def transformers
      @transformers ||= {}.with_indifferent_access
    end

    def permitted_params
      scalar_params.to_params
    end

    def transformed_keys
      @transformed_keys ||= scalar_params
    end

    # @param [ActionController::Parameters] params
    def run_transformers!(params)
      @transformers.each { |key, t| params[key] = t.call(params[key]) }
    end
  end
end
