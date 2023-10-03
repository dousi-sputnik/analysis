FactoryBot.define do
  factory :analysis_result do
    association :analysis_session
    jan_code { "4900000000001" }
    product_name { "偽のABC分析本" }
    sales { 1000 }
    cumulative_sales { 10000.0 }
    cumulative_percentage { 10.0 }
    classification { "A" }
    yahoo_url { "http://yahoo.co.jp/some_product" }
  end
end
