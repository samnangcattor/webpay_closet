module Util
  def stringify_keys(hash)
    Hash[hash.map { |k, v| [k.to_s, v] }]
  end
end

module WebPayMock
  include Util

  def customer_from(params, overrides = {})
    params = stringify_keys(params)
    builder = ResponseObjectBuilder.new('customer')
    builder.set_from(email: nil, description: nil, active_card: nil)
    builder.set_from(params, :email, :description)
    card = params['card']
    case card
    when Hash
      builder[:active_card] = card_builder_from(card).hash
    when String
      builder[:active_card] = dummy_card
    end
    builder.set_from(overrides).build
  end

  def charge_from(params, overrides = {})
    params = stringify_keys(params)
    builder = ResponseObjectBuilder.new('charge')
    builder.set_from(amount_refunded: 0, paid: true, refunded: false, failure_message: nil, captured: true, expire_time: nil)
    builder.set_from(params, :amount, :currency, :description)
    card = params['card']
    case card
    when Hash
      builder[:card] = card_builder_from(card).hash
    when String
      builder[:card] = dummy_card
    end
    if customer = params['customer']
      builder[:card] = dummy_card
      builder[:customer] = customer
    end
    if params['capture'] == false
      builder[:captured] = builder[:paid] = false
      builder[:expire_time] = Time.now.to_i + 60 * 60 * 24 * 7
    end
    builder.set_from(overrides).build
  end

  def card_builder_from(params)
    params = stringify_keys(params)
    number = params['number']
    ResponseObjectBuilder.new('card')
      .set_from(params, :exp_month, :exp_year, :name)
      .set_from(
        fingerprint: '215b5b2fe460809b8bb90bae6eeac0e0e0987bd7',
        country: 'JP',
        type: 'Visa',
        cvc_check: 'pass',
        last4: number[-4..-1]
      )
  end

  def dummy_card
    { "object"=>"card",
      "exp_year"=>2014,
      "exp_month"=>11,
      "fingerprint"=>"215b5b2fe460809b8bb90bae6eeac0e0e0987bd7",
      "name"=>"KEI KUBO",
      "country"=>"JP",
      "type"=>"Visa",
      "cvc_check"=>"pass",
      "last4"=>"4242" }
  end

  def card_error(attributes = {})
    {
      status: 402,
      body: { error: {
          "type" => "card_error",
          "message" => "This card cannot be used.",
          "code" => "card_declined"
        }.merge(stringify_keys(attributes)) }.to_json
    }
  end

  class ResponseObjectBuilder
    include Util
    PREFIX = {
      charge: 'ch',
      customer: 'cus',
      token: 'tok',
      event: 'evt',
      account: 'acct'
    }.freeze
    ID_LETTERS = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a

    attr_reader :hash

    def initialize(object)
      @hash = {}
      @hash['object'] = object.to_s
      return if @hash['object'] == 'card'
      @hash['id'] = PREFIX[object.to_sym] + '_' + 15.times.map { ID_LETTERS[rand(ID_LETTERS.length)] }.join
      return if @hash['object'] == 'account'
      @hash['livemode'] = false
      @hash['created'] = Time.now.to_i
    end

    def []=(key, value)
      @hash[key.to_s] = value
    end

    def set_from(hash, *allowed_keys)
      allowed_string_keys = allowed_keys.map(&:to_s)
      hash.each do |k, v|
        @hash[k.to_s] = v if allowed_string_keys.empty? || allowed_string_keys.include?(k.to_s)
      end
      self
    end

    def build
      stringify_keys(@hash)
    end
  end
end

RSpec.configure do |config|
  config.include WebPayMock
end
