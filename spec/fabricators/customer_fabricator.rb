Fabricator(:customer) do
  name { Faker::Name.name }
  email { |attrs| "#{attrs[:name].parameterize}@example.com" }
  password { 'cusomerPass' }
  address { Faker::Address.street_address }
  disabled false
end
