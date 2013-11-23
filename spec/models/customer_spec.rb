require 'spec_helper'
describe Customer do
  describe '#buy' do
    let(:customer) { Fabricate(:customer, webpay_customer_id: 'cus_XXXXXXXXX') }
    let(:item) { Fabricate(:item) }

    context 'when the transaction succeeds' do
      let(:charge_id) { 'ch_YYYYYYYYY' }
      before do
        expect(WebPay::Charge).to receive(:create)
          .with(customer: customer.webpay_customer_id, amount: item.price, currency: 'jpy')
          .and_return(WebPay::Charge.new('id' => charge_id, 'paid' => true))
      end

      it 'should create a sale' do
        expect { customer.buy(item) }.to change(Sale, :count).by(1)
      end

      it 'should set sale.webpay_charge_id' do
        customer.buy(item)
        expect(Sale.last.webpay_charge_id).to eq charge_id
      end
    end
  end
end
