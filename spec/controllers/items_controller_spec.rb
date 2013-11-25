require 'spec_helper'
describe ItemsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:customer]
  end

  describe '#buy' do
    let(:item) { Fabricate(:item, price: 1293) }

    context 'customer is logged in' do
      let(:customer) { Fabricate(:customer, webpay_customer_id: 'cus_XXXXXXXXX') }
      before { sign_in customer }

      it 'should buy the item with customer id' do
        expect(WebPay::Charge).to receive(:create)
          .with(customer: customer.webpay_customer_id, amount: item.price, currency: 'jpy')
          .and_return(WebPay::Charge.new('id' => 'ch_YYYYYYYYY', 'paid' => true))
        expect { post :buy, id: item.id }.to change(Sale, :count).by(1)
      end
    end

    context 'customer is not logged in' do
      let(:token) { 'tok_XXXXXXXXX' }
      it 'should by the item with the token in request' do
        expect(WebPay::Charge).to receive(:create)
          .with(card: token, amount: item.price, currency: 'jpy', description: 'Tokyo-to Chiyoda-ku John Doe')
          .and_return(WebPay::Charge.new('id' => 'ch_YYYYYYYYY', 'paid' => true))
        expect { post :buy, id: item.id, address: 'Tokyo-to Chiyoda-ku',  name: 'John Doe', 'webpay-token' => token }.
          not_to change(Sale, :count)
      end
    end
  end
end
