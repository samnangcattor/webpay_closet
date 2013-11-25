require 'spec_helper'
describe ItemsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:customer]
  end

  describe '#buy' do
    context 'customer is logged in' do
      let(:price) { 1293 }
      let(:customer) { Fabricate(:customer, webpay_customer_id: 'cus_XXXXXXXXX') }
      let(:item) { Fabricate(:item, price: price) }
      before { sign_in customer }

      it 'should buy the item with customer id' do
        expect(WebPay::Charge).to receive(:create)
          .with(customer: customer.webpay_customer_id, amount: item.price, currency: 'jpy')
          .and_return(WebPay::Charge.new('id' => 'ch_YYYYYYYYY', 'paid' => true))
        expect { post :buy, id: item.id }.to change(Sale, :count).by(1)
      end
    end
  end
end
