class Customers::RegistrationsController < Devise::RegistrationsController
  def create
    self.resource = customer = Customer.new(sign_up_params)
    if customer.save
      sign_up(:customer, customer)
      begin
        customer.update_webpay_customer_id
        notice = [:signed_up]
        location = after_sign_up_path_for(customer)
      rescue WebPay::ApiError => e
        notice = ['signed_up_but_webpay_error', message: e.data.error.message]
        location = edit_customer_registration_path
      end

      set_flash_message :notice, *notice if is_flashing_format?
      respond_with customer, :location => location
    else
      clean_up_passwords customer
      respond_with customer
    end
  end

  def update
    self.resource = customer = current_customer
    if customer.update_with_password(account_update_params)
      sign_in :customer, customer, :bypass => true

      begin
        customer.update_webpay_customer_id
        notice = [:updated]
        location = after_update_path_for(customer)
      rescue WebPay::ApiError => e
        notice = ['updated_but_webpay_error', message: e.data.error.message]
        location = edit_customer_registration_path
      end

      set_flash_message :notice, *notice if is_flashing_format?
      respond_with customer, :location => location
    else
      clean_up_passwords customer
      respond_with customer
    end
  end
end
