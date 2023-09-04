class AnalysisSession < ApplicationRecord
  belongs_to :user
  has_many :analysis_results, dependent: :destroy
end
