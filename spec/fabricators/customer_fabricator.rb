Fabricator(:customer) do
  email { |attrs| "#{attrs[:name].parameterize}@example.com" }
  password { 'cusomerPass' }
  name { Faker::Name.name }
  address { Faker::Address.street_address }
  disabled false
end
