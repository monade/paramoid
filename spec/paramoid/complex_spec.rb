# frozen_string_literal: true

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
          items: [{}, { sub_items: [{ id: 5 }] }]
        }
      end
      it 'has the default value for those' do
        expect(sanitized.to_unsafe_h).to eq(
          {
            'buyer' => { 'payment_method' => { 'uuid' => 1 } },
            'total' => 0,
            'name' => 'some_name',
            'items' => [
              { 'price' => 0 },
              { 'price' => 0, 'sub_items' => [{ 'price' => 0, 'id' => 5 }] }
            ],
            'person_attributes' => { 'role' => :user }
          }
        )
      end

      context 'and the required parameter is missing' do
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
            items: [{}, { sub_items: [{ price: 5 }] }]
          }
        end

        it 'raises an error' do
          expect { sanitized }.to raise_error(
            ActionController::ParameterMissing,
            'param is missing or the value is empty: items.sub_items.id'
          )
        end
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

    it 'returns permitted params' do
      expect(subject.permitted_params).to eq(
        [
          :total, :name,
          { buyer: [{ payment_method: [:id] }],
            items: [:id, :name, :price, :discount, { sub_items: [:id, :price] }],
            person: %i[id full_name role] }
        ]
      )
    end

    it 'has the default values correctly nested' do
      expect(sanitized.to_unsafe_h).to eq(
        {
          'buyer' => { 'payment_method' => { 'uuid' => 1 } },
          'items' => [
            { 'price' => 0, 'name' => 'some_name', 'discount' => 0.1, 'id' => 5 }
          ],
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
        name: 'some_name',
        buyer: {
          payment_method: {}
        }
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
