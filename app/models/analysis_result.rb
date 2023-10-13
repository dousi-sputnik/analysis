class AnalysisResult < ApplicationRecord
  belongs_to :analysis_session
  has_one :user, through: :analysis_session
end
