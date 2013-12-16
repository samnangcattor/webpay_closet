require 'spec_helper'
describe Item do
  describe '#bought_by_customer' do
    let(:customer) { Fabricate(:customer, webpay_customer_id: 'cus_XXXXXXXXX') }
    let(:item) { Fabricate(:item) }

    context 'when the customer does not have an webpay account' do
      before { customer.update!(webpay_customer_id: nil) }
      it 'should raise NoWebPayAccountError' do
        expect { item.bought_by_customer(customer) }.to raise_error(Customer::NoWebPayAccountError)
      end
    end

    context 'when the transaction succeeds' do
      let(:expected_params) { { customer: customer.webpay_customer_id, amount: item.price, currency: 'jpy' } }
      let(:dummy_charge) { charge_from(expected_params) }

      before do
        stub_request(:post, 'https://api.webpay.jp/v1/charges')
          .with(expected_params)
          .to_return(body: dummy_charge.to_json)
      end

      it 'should create a sale' do
        expect { item.bought_by_customer(customer) }.to change(Sale, :count).by(1)
      end

      it 'should set sale.webpay_charge_id' do
        item.bought_by_customer(customer)
        expect(Sale.last.webpay_charge_id).to eq dummy_charge['id']
      end
    end

    context 'when the transaction fails' do
      before do
        stub_request(:post, 'https://api.webpay.jp/v1/charges')
          .with(customer: customer.webpay_customer_id, amount: item.price, currency: 'jpy')
          .to_return(card_error)
      end

      it 'should not create a sale' do
        expect { item.bought_by_customer(customer) rescue nil }.not_to change(Sale, :count)
      end

      it 'should raise ChargeFailed error' do
        expect { item.bought_by_customer(customer) }.to raise_error(Item::ChargeFailed, "This card cannot be used.")
      end
    end
  end
end
