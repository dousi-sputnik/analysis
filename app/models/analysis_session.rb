class AnalysisSession < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :analysis_results, dependent: :destroy

  validates :title, presence: { message: "タイトルは必須です。" }, length: { maximum: 50, message: "タイトルは最大50字までです。" }
  validates :description, presence: { message: "説明は必須です。" }, length: { maximum: 500, message: "説明文は最大500字までです。" }

  after_save :limit_analysis_sessions

  def analysis!
    items = self.items.order(sales: :desc)
    total_sales = items.sum(:sales)
    cumulative_sales = 0

    ActiveRecord::Base.transaction do
      analysis_results.destroy_all

      items.each do |item|
        cumulative_sales += item.sales
        cumulative_percentage = (cumulative_sales.to_f / total_sales) * 100

        if cumulative_percentage <= 70
          item_classification = "A"
        elsif cumulative_percentage <= 90
          item_classification = "B"
        else
          item_classification = "C"
        end

        analysis_results.create!(
          jan_code: item.jan_code,
          product_name: item.product_name,
          sales: item.sales,
          cumulative_sales: cumulative_sales,
          cumulative_percentage: cumulative_percentage,
          classification: item_classification
        )
      end
    end
  end

  private

  def limit_analysis_sessions
    user_sessions = user.analysis_sessions.order(created_at: :asc)
    excess_count = user_sessions.count - User::MAX_ANALYSIS_SESSIONS
    if excess_count > 0
      oldest_sessions = user_sessions.limit(excess_count)
      oldest_sessions.destroy_all
    end
  end
end
