FactoryBot.define do
  factory :user do
    email { Faker::Internet.free_email }
    password { SecureRandom.hex(8) }
  end
end