require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe ComplexParamsSanitizer, type: :controller do
  let(:params) do
    ActionController::Parameters.new(params_hash)
  end

  subject { described_class.new(user) }
  let(:sanitized) { subject.sanitize(params) }

  describe 'when params are valid' do
    let(:user) { double(admin?: false) }
    let(:params_hash) do
      {

        unwanted: 1,
        name: 'some_name',
        buyer: {
          payment_method: {
            id: 1
          }
        }
      }
    end
    let(:params) do
      ActionController::Parameters.new(params_hash)
    end

    it 'filters out unwanted params' do
      expect(sanitized).not_to have_key(:unwanted)
    end

    it 'has the default values of existing objects' do
      expect(sanitized.to_unsafe_h).to eq(
        {
          'buyer' => { 'payment_method' => { 'uuid' => 1 } },
          'total' => 0,
          'name' => 'some_name'
        }
      )
    end

    context 'when a nested object has at least a value' do
      let(:params_hash) do
        {

          unwanted: 1,
          name: 'some_name',
          buyer: {
            payment_method: {
              id: 1
            }
          },
          person: {},
          items: [{}, {}]
        }
      end
      it 'has the default value for those' do
        expect(sanitized.to_unsafe_h).to eq(
          {
            'buyer' => { 'payment_method' => { 'uuid' => 1 } },
            'total' => 0,
            'name' => 'some_name',
            'items' => [{ 'price' => 0 }, { 'price' => 0 }],
            'person_attributes' => { 'role' => :user }
          }
        )
      end
    end
  end

  describe 'when params all parameters are set' do
    let(:user) { double(admin?: true) }
    let(:params_hash) do
      {
        name: 'some_name',
        unwanted: 1,
        buyer: {
          payment_method: {
            id: 1
          }
        },
        items: [{ id: 5, name: 'some_name', discount: 10 }],
        total: 100,
        person: { id: 1, full_name: 'some_name' }

      }
    end
    let(:params) do
      ActionController::Parameters.new(params_hash)
    end

    it 'has the default values correctly nested' do
      expect(sanitized.to_unsafe_h).to eq(
        {
          'buyer' => { 'payment_method' => { 'uuid' => 1 } },
          'items' => [{ 'price' => 0, 'name' => 'some_name', 'discount' => 0.1, 'id' => 5 }],
          'total' => 100,
          'name' => 'some_name',
          'person_attributes' => { 'role' => :admin, 'id' => 1, 'full_name' => 'some_name' }
        }
      )
    end
  end

  describe 'when required params are missing' do
    let(:user) { double(admin?: false) }
    let(:params_hash) do
      {
        name: 'some_name'
      }
    end

    it 'raises an error' do
      expect { sanitized }.to raise_error(
        ActionController::ParameterMissing,
        'param is missing or the value is empty: buyer.payment_method.id'
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
