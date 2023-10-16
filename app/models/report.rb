class Report < ApplicationRecord
  belongs_to :analysis_session
  has_one :user, through: :analysis_session
  validates :overview, length: { maximum: 2000 }
  validates :rank_a_trend, length: { maximum: 2000 }
  validates :rank_b_trend, length: { maximum: 2000 }
  validates :rank_c_trend, length: { maximum: 2000 }
end
