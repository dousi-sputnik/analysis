FactoryBot.define do
  factory :analysis_result do
    association :analysis_session
    sequence(:jan_code, "4900000000001") { |n| n.to_s }
    product_name { "偽のABC分析本" }
    sales { 1000 }
    cumulative_sales { 10000.0 }
    cumulative_percentage { 10.0 }
    classification { "A" }
  end
end
