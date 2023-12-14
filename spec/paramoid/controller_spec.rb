# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'controllers' do
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

  describe PeopleInlineController, type: :controller do
    let(:params) do
      ActionController::Parameters.new(params_hash)
    end

    it 'sanitizes params in a block' do
      allow_any_instance_of(described_class).to receive(:params).and_return(params)
      expect_any_instance_of(Paramoid::Base).to receive(:instance_exec).and_call_original

      subject.index
    end
  end

  describe PeopleController, type: :controller do
    let(:params) do
      ActionController::Parameters.new(params_hash)
    end

    it 'sanitizes params in a block' do
      allow_any_instance_of(described_class).to receive(:params).and_return(params)
      expect_any_instance_of(PersonParamsSanitizer).to receive(:sanitize)
      subject.index
    end
  end
end
# rubocop:enable Metrics/BlockLength
