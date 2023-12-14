module Paramoid
  # rubocop:disable Metrics/ClassLength
  class Object
    # @return [Symbol] the parameter name
    attr_reader :name
    # @return [Symbol] the parameter alias
    attr_reader :alias_name
    # @return [Object] the parameter nested
    attr_reader :nested
    # @return [Object] the parameter default value
    attr_reader :default
    # @return [Lambda, NilClass] the transformer
    attr_reader :transformer
    # @return [TrueClass, FalseClass] required
    attr_reader :required

    # @param [Symbol] name
    # @param [Symbol] alias_name
    # @param [Object, NilClass] nested
    # @param [Object] default
    # @param [Lambda, NilClass] transformer
    # @param [TrueClass, FalseClass] required
    def initialize(name, alias_name, nested: nil, nesting_type: nil, transformer: nil, default: nil, required: false)
      @name = name
      @alias = alias_name
      @nested = nested
      @default = default
      @transformer = transformer
      @required = required
      @nesting_type = nesting_type
    end

    # @param [Array, Hash] params
    def transform_params!(params)
      if params.is_a?(Array)
        params.each { |param| transform_params!(param) }
        return
      end

      return unless params.key?(@name)

      params[@name] = @transformer.call(params[@name]) if @transformer.respond_to?(:call)

      @nested.transform_params!(params[@name]) if nested?
      params[@alias] = params.delete(@name) unless @alias == @name
    end

    def to_params
      if nested?
        { @name.to_sym => @nested.to_params }
      else
        @name
      end
    end

    # @return [Hash] the required params
    def to_required_params
      if nested?
        @nested.to_required_params
      else
        @required ? [@name] : []
      end
    end

    # @param [Hash] params
    # @param [Array<Symbol>] path
    # @raise [ActionController::ParameterMissing] if one of the required params is missing
    def ensure_required_params!(params, path: [])
      current_path = [*path, @name]

      _raise_on_missing_parameter!(params, output_key, current_path) if @required

      return params unless nested?

      ensure_required_nested_params!(params, current_path)
    end

    def ensure_required_nested_params!(params, current_path)
      if params.is_a?(Array)
        params.flatten.each do |param|
          @nested.ensure_required_params!(param[output_key], path: current_path)
        end
      else
        @nested.ensure_required_params!(params ? params[output_key] : nil, path: current_path)
      end

      params
    end

    # @param [Hash] params
    # @return [Hash] the params with the default values
    def apply_defaults!(params)
      return apply_nested_defaults!(params) if nested?

      return params unless @default

      return params if @nesting_type == :list && !params

      params ||= {}
      apply_scalar_defaults!(params)

      params
    end

    def apply_scalar_defaults!(params)
      if params.is_a?(Array)
        params.map! { |param| apply_scalar_defaults!(param) }
      else
        params[output_key] ||= @default
      end
      params
    end

    def apply_nested_defaults!(params)
      return params unless params

      params ||= @nesting_type == :list ? [] : {}

      return apply_nested_param_default_when_available!(params, output_key) unless params.is_a?(Array)

      params.map! do |param|
        apply_nested_param_default_when_available!(param, output_key)
      end
      params
    end

    def apply_nested_param_default_when_available!(param, key)
      return param unless param[key]

      result = @nested.apply_defaults!(param[key])
      param[key] = result if result
      param
    end

    def to_defaults
      if nested?
        nested_defaults = @nested.to_defaults
        (nested_defaults.present? ? { output_key => nested_defaults } : {}).with_indifferent_access
      else
        (@default ? { output_key => @default } : {}).with_indifferent_access
      end
    end

    def output_key
      @output_key ||= (@alias || @name).to_s
    end

    def <<(value)
      @nested << value
    end

    def nested?
      !@nested.nil?
    end

    private

    def _raise_on_missing_parameter!(params, key, current_path)
      return if _param_exist?(params, key)

      raise ActionController::ParameterMissing, current_path.join('.')
    end

    def _param_exist?(params, key)
      params&.key?(key) && !params[key].nil?
    end
  end
end
