require 'spec_helper'

describe Paramoid::Object do
  let(:name) { :some_param }
  let(:alias_name) { :some_param }
  let(:required) { false }
  let(:default) { nil }
  let(:transformer) { nil }
  let(:nested) { nil }
  subject { described_class.new(name, alias_name, nested: nested, transformer: transformer, default: default, required: required) }
  let(:sanitized) { subject.sanitize(params) }

  describe '#to_params' do
    it 'returns the name' do
      expect(subject.to_params).to eq(name)
    end

    context 'when it\'s nested' do
      let(:nested) { described_class.new(:nested, nil) }

      it 'returns the child' do
        expect(subject.to_params).to eq({ name => nested.to_params })
      end
    end
  end

  describe '#to_defaults' do
    it 'returns an empty value' do
      expect(subject.to_defaults).to eq({})
    end

    context 'when there\'s a default' do
      let(:default) { 'some_default' }

      it 'returns the default value' do
        expect(subject.to_defaults).to eq({ name.to_s => default })
      end

      context 'when there\'s an alias' do
        let(:alias_name) { :alias_name }

        it 'returns the default value with the alias' do
          expect(subject.to_defaults).to eq({ alias_name.to_s => default })
        end
      end
    end

    context 'when it\'s nested' do
      let(:nested) { described_class.new(:nested, :nested, default: 'my_child_default') }

      it 'returns the child' do
        expect(subject.to_defaults).to eq({ name.to_s => nested.to_defaults })
      end
    end
  end

  describe '#to_required_params' do
    it 'returns an empty list' do
      expect(subject.to_required_params).to eq([])
    end

    context 'when it\'s required' do
      let(:required) { true }

      it 'returns the name' do
        expect(subject.to_required_params).to eq([name])
      end
    end

    context 'when it\'s nested' do
      let(:nested) { described_class.new(:nested, nil, required: true) }

      it 'returns the child' do
        expect(subject.to_params).to eq({ name => nested.to_params })
      end
    end
  end

  describe '#ensure_required_params!' do
    let(:params_hash) { { 'not_this_param' => 'some_value' } }
    let(:params) { ActionController::Parameters.new(params_hash) }

    it 'returns the params' do
      expect(subject.ensure_required_params!(params)).to eq(params)
    end

    context 'when it\'s required' do
      let(:required) { true }

      it 'raises an error' do
        expect { subject.ensure_required_params!(params) }.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: some_param')
      end
    end

    context 'when it\'s nested' do
      let(:nested) { described_class.new(:nested, nil, required: true) }

      it 'raises an error' do
        expect { subject.ensure_required_params!(params) }.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: nested')
      end

      context 'and it\'s required' do
        let(:required) { true }

        it 'raises an error on the parent param' do
          expect { subject.ensure_required_params!(params) }.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: some_param')
        end
      end
    end
  end
end
