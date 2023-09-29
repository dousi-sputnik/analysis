class AnalysisSession < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :analysis_results, dependent: :destroy

  validates :title, presence: { message: "タイトルは必須です。" }, length: { maximum: 50, message: "タイトルは最大50字までです。"}
  validates :description, presence: { message: "説明は必須です。" }, length: { maximum: 500, message: "説明文は最大500字までです。"}

  def analysis!
    items = self.items.order(sales: :desc)
    total_sales = items.sum(:sales)
    cumulative_sales = 0

    # DBのトランザクションを開始
    ActiveRecord::Base.transaction do
      # Clear existing analysis_results
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

        # ! を使用して、エラーが発生した場合に例外を発生させる
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
end
