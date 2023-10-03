FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'Password1' }
    password_confirmation { 'Password1' }
    name { "アナリストABC" }
    confirmed_at { Date.today }
  end
end
