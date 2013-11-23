class Customers::RegistrationsController < Devise::RegistrationsController
  def create
    customer = Customer.new(sign_up_params)
    if customer.save
      customer.update_webpay_customer_id
      set_flash_message :notice, :signed_up if is_flashing_format?
      sign_up(:customer, customer)
      respond_with customer, :location => after_sign_up_path_for(customer)
    else
      clean_up_passwords customer
      respond_with customer
    end
  end

  def update
    customer = current_customer
    if customer.update_with_password(account_update_params)
      set_flash_message :notice, :updated if is_flashing_format?
      sign_in :customer, customer, :bypass => true
      respond_with customer, :location => after_update_path_for(customer)
    else
      clean_up_passwords customer
      respond_with customer
    end
  end
end
