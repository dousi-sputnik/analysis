class AnalysisSessionsController < ApplicationController
  def analysis
    @analysis_session = current_user.analysis_sessions.find(params[:id])
    items = @analysis_session.items.order(sales: :desc)
    total_sales = items.sum(:sales)
    cumulative_sales = 0

    # Clear existing analysis_results
    @analysis_session.analysis_results.destroy_all
  
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
  
      @analysis_session.analysis_results.create!(
        jan_code: item.jan_code,
        product_name: item.product_name,
        sales: item.sales,
        cumulative_sales: cumulative_sales,
        cumulative_percentage: cumulative_percentage,
        classification: item_classification
      )
    end

    # Excel出力のための処理を追加
    respond_to do |format|
      format.html { redirect_to analysis_session_path(@analysis_session) }
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="abc_analysis.xlsx"'
      }
    end
  end

  def show
    @analysis_session = current_user.analysis_sessions.find(params[:id])
    @abc_items = @analysis_session.analysis_results
  end
end

