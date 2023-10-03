FactoryBot.define do
  factory :analysis_session do
    association :user
    title { "ABCanalysisのタイトル" }
    description { "ABCanalysisの説明" }
  end
end
