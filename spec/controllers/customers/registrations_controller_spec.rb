require 'spec_helper'
describe Customers::RegistrationsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:customer]
  end

  describe '#create' do
    let(:basic_params) {{
        email: 'test@example.com',
        password: 'password',
        password_confirmation: 'password',
        name: 'Foo Bar',
        address: 'Tokyo-to'
      }}

    it 'should create customer without webpay_token' do
      expect { post :create, customer: basic_params }.to change(Customer, :count).by(1)
      expect(Customer.last.webpay_customer_id).to eq nil
    end

    it 'should create customer with webpay_token' do
      token_id = 'tok_XXXXXXXXX'
      customer_id = 'cus_YYYYYYYYY'
      expect(WebPay::Customer).to receive(:create)
        .with(card: token_id, email: basic_params[:email], description: basic_params[:name])
        .and_return(WebPay::ResponseConverter.new.convert('id' =>  customer_id, 'object' => 'customer'))
      expect { post :create, customer: basic_params.merge('webpay_token' => token_id) }.to change(Customer, :count).by(1)
      expect(Customer.last.webpay_customer_id).to eq customer_id
    end
  end
end
