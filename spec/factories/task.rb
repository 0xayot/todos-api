FactoryBot.define do
  factory :task do
    association :user

    title { Faker::Lorem.sentence }
    completed {false}
    note { Faker::Lorem.paragraph }


    trait :completed do
      completed {true}
    end
    
  end
end