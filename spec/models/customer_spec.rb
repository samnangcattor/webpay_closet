require 'spec_helper'
describe Customer do
  describe '#buy' do
    let(:customer) { Fabricate(:customer, webpay_customer_id: 'cus_XXXXXXXXX') }
    let(:item) { Fabricate(:item) }

    context 'when the customer does not have an webpay account' do
      before { customer.update!(webpay_customer_id: nil) }
      it 'should raise NoWebPayAccountError' do
        expect { customer.buy(item) }.to raise_error(Customer::NoWebPayAccountError)
      end
    end

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

    context 'when the transaction fails' do
      before do
        expect(WebPay::Charge).to receive(:create)
          .with(customer: customer.webpay_customer_id, amount: item.price, currency: 'jpy')
          .and_raise(WebPay::CardError.new(402, {
              "type" => "card_error",
              "message" => "This card cannot be used.",
              "code" => "card_declined"
            }))
      end

      it 'should not create a sale' do
        expect { customer.buy(item) rescue nil }.not_to change(Sale, :count)
      end

      it 'should raise ChargeFailed error' do
        expect { customer.buy(item) }.to raise_error(Customer::ChargeFailed, "This card cannot be used.")
      end
    end
  end
end
