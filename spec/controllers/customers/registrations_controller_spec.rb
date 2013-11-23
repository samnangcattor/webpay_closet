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

    context 'if WebPay responds error' do
      let(:token_id) { 'tok_XXXXXXXXX' }

      before do
        expect(WebPay::Customer).to receive(:create)
          .with(card: token_id, email: basic_params[:email], description: basic_params[:name])
          .and_raise(WebPay::CardError.new(402, {
              "type" => "card_error",
              "message" => "This card cannot be used.",
              "code" => "card_declined"
            }))
      end

      def do_request
        post :create, customer: basic_params.merge('webpay_token' => token_id)
      end

      it 'should create customer without webpay_customer_id' do
        expect { do_request }.to change(Customer, :count).by(1)
        expect(Customer.last.webpay_customer_id).to eq nil
      end

      it 'should redirect to customer edit page' do
        do_request
        expect(response).to redirect_to(edit_customer_registration_path)
      end

      it 'should set notice with error message' do
        do_request
        expect(flash[:notice]).to eq I18n.t('devise.registrations.customer.signed_up_but_webpay_error', message: "This card cannot be used.")
      end
    end
  end
end
