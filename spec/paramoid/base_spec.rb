# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe PersonParamsSanitizer, type: :controller do
  let(:params) do
    ActionController::Parameters.new(params_hash)
  end

  subject { described_class.new(user) }
  let(:sanitized) { subject.sanitize(params) }

  describe 'when params are valid' do
    let(:user) { double(admin?: false) }
    let(:params_hash) do
      {
        current_user_id: 2,
        first_name: 'John',
        last_name: 'Doe',
        email: 'Hello@MyCustomMAIL.COM',
        role: 'some_role',
        unwanted: 'hello',
        an_object_filtered: { name: 'value' },
        an_array_filtered: [{ name: 'value' }],
        an_array_unfiltered: [1, 2, 3, 4, 5]
      }
    end

    it 'filters out unwanted params' do
      expect(sanitized).not_to have_key(:unwanted)
    end

    it 'filters out object values if it\'s not a group' do
      expect(sanitized).not_to have_key('an_object_filtered')
    end

    it 'filters out object values if it\'s not an array' do
      expect(sanitized).not_to have_key('an_array_filtered')
    end

    it 'keeps only allowed params' do
      expect(sanitized.to_unsafe_h).to eq(
        {
          'current_user_id' => 2,
          'first_name' => 'John',
          'last_name' => 'Doe',
          'email' => 'hello@mycustommail.com',
          'some_default' => 1,
          'an_array_unfiltered' => [1, 2, 3, 4, 5]
        }
      )
    end

    context 'when the required value is not set' do
      let(:params_hash) do
        {}
      end
      it 'raises an error' do
        expect { sanitized }.to raise_error(
          ActionController::ParameterMissing,
          /param is missing or the value is empty( or invalid)?: current_user_id/
        )
      end
    end

    context 'when the default is set' do
      let(:params_hash) do
        { some_default: 2, current_user_id: 1 }
      end
      let 'it replaces the default value' do
        expect(sanitized['some_default']).to eq(2)
      end
    end

    context 'when the user is an admin' do
      let(:user) { double(admin?: true) }

      it 'keeps role param' do
        expect(sanitized).to have_key('role')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
