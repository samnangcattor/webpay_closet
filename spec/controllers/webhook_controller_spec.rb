require 'rails_helper'

describe WebhookController do
  describe '#index' do
    let(:customer) { Fabricate(:customer, webpay_customer_id: 'cus_XXXXXXXXX') }
    let(:item) { Fabricate(:item) }
    let(:recursion) { Fabricate(:recursion, webpay_recursion_id: 'rec_XXXXXXXXX', customer_id: customer.id, item_id: item.id) }

    context 'params[:type] is charge.succeeded' do
      let(:params) do
        {
          type: 'charge.succeeded',
          data: {
            object: {
              id: 'ch_XXXXXXXXX'
            }
          }
        }
      end

      context 'params[:data][:object] has recursion key' do
        before(:each) do
          params[:data][:object][:recursion] = recursion.webpay_recursion_id
        end

        it 'should be success and a sale is created' do
          expect(response).to be_ok
          expect { post('index', params) }.to change(Sale, :count).by(1)
        end
      end

      context 'params[:data][:object] has not recursion key' do
        before(:each) do
          params[:data][:object][:recursion] = nil
        end

        it 'should be success and no sale is created' do
          expect(response).to be_ok
          expect { post('index', params) }.to change(Sale, :count).by(0)
        end
      end
    end

    context 'params[:type] is not charge.succeeded' do
      let(:params) do
        {type: 'charge.failed'}
      end

      it 'should be success and no sale is created' do
        expect(response).to be_ok
        expect { post('index', params) }.to change(Sale, :count).by(0)
      end
    end
  end
end
