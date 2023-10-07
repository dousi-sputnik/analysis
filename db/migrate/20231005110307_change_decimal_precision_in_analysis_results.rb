class ChangeDecimalPrecisionInAnalysisResults < ActiveRecord::Migration[6.1]
  def change
    change_column :analysis_results, :cumulative_sales, :decimal, precision: 10, scale: 2
    change_column :analysis_results, :cumulative_percentage, :decimal, precision: 10, scale: 2
  end
end
