module WebPayClient
  def webpay
    @webpay ||= WebPay.new(Rails.application.config.webpay_secret_key)
  end
end
