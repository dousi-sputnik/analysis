FactoryBot.define do
  factory :item do
    association :user
    association :analysis_session
    sequence(:jan_code) { |n| "49000000000#{n}" }
    product_name { "偽のABC分析本" }
    sales { 1000 }
  end
end
