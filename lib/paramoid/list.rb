# frozen_string_literal: true

module Paramoid
  class List < Array
    def to_params
      list = reject(&:nested?).map(&:to_params)
      nested = select(&:nested?).inject({}) { |a, b| a.merge!(b.to_params) }
      nested.present? ? list << nested : list
    end

    def transform_params!(params)
      each do |params_data|
        params_data.transform_params! params
      end
    end

    def apply_defaults!(params)
      each do |params_data|
        params = params_data.apply_defaults! params
      end
      params
    end

    def to_defaults
      inject({}) { |a, b| a.merge!(b.to_defaults) }
    end

    def ensure_required_params!(params, path: [])
      each do |params_data|
        params_data.ensure_required_params! params, path: path
      end
    end
  end
end
