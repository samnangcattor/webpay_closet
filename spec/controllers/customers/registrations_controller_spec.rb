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

    it 'should create customer without webpay-token' do
      expect { post :create, customer: basic_params }.to change(Customer, :count).by(1)
      expect(Customer.last.webpay_customer_id).to eq nil
    end
  end
end
