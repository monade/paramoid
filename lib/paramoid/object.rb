module Paramoid
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
    def initialize(name, alias_name, nested: nil, transformer: nil, default: nil, required: false)
      @name = name
      @alias = alias_name
      @nested = nested
      @default = default
      @transformer = transformer
      @required = required
    end

    # @param [Array, Hash] params
    def transform_params!(params)
      return if @alias == @name

      if params.is_a?(Array)
        params.each { |param| transform_params!(param) }
        return
      end

      return unless params.key?(@name)

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

    def to_defaults
      key = @alias || @name
      if nested?
        nested_defaults = @nested.to_defaults
        (nested_defaults.present? ? { key => @nested.to_defaults } : {}).with_indifferent_access
      else
        (@default ? { key => @default } : {}).with_indifferent_access
      end
    end

    def <<(value)
      @nested << value
    end

    def nested?
      !@nested.nil?
    end
  end
end
