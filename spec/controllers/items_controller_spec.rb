require 'rails_helper'
describe ItemsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:customer]
  end

  describe '#index' do
    describe '@has_card' do
      let(:id) { 'cus_XXXXXXXXX' }
      let(:customer) { Fabricate(:customer, webpay_customer_id: id) }
      def stub(attributes = {})
        webpay_stub(:customers, :retrieve, params: { id: id }, overrides: attributes)
      end

      it 'should be true if customer has card' do
        stub(active_card: fake_card)
        sign_in customer
        get :index
        expect(assigns(:has_card)).to eq true
      end

      it 'should be false if customer does not have card' do
        stub()
        get :index
        expect(assigns(:has_card)).to eq false
      end

      it 'should be false if not logged in' do
        get :index
        expect(assigns(:has_card)).to eq false
      end
    end
  end

  describe '#buy' do
    let(:item) { Fabricate(:item, price: 1293) }

    context 'customer is logged in' do
      let(:customer) { Fabricate(:customer, webpay_customer_id: 'cus_XXXXXXXXX') }
      before { sign_in customer }

      it 'should buy the item with customer id' do
        params = { customer: customer.webpay_customer_id, amount: item.price, currency: 'jpy' }
        webpay_stub(:charges, :create, params: params)
        expect { post :buy, id: item.id }.to change(Sale, :count).by(1)
      end
    end

    context 'customer is not logged in' do
      let(:token) { 'tok_XXXXXXXXX' }
      it 'should by the item with the token in request' do
        params = { card: token, amount: item.price, currency: 'jpy', description: 'Tokyo-to Chiyoda-ku John Doe' }
        webpay_stub(:charges, :create, params: params)
        expect { post :buy, id: item.id, address: 'Tokyo-to Chiyoda-ku',  name: 'John Doe', 'webpay-token' => token }.
          not_to change(Sale, :count)
      end
    end
  end
end
