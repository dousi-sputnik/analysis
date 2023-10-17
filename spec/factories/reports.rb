FactoryBot.define do
  factory :report do
    association :analysis_session
    overview { "ABC分析の概要" }
    rank_a_trend { "Aランクのトレンド" }
    rank_b_trend { "Bランクのトレンド" }
    rank_c_trend { "Cランクのトレンド" }
  end
end
