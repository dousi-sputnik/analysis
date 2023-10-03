class AnalysisSessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_analysis_session, only: [:show, :destroy, :show_item]

  def show
    @abc_items = @analysis_session.analysis_results

    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="abc_analysis.xlsx"'
        render xlsx: 'analysis', template: 'analysis_sessions/analysis'
      end
    end
  end

  def show_item
    app_id = ENV['YAHOO_APP_ID']
    jan_code = params[:jan_code].strip
    if jan_code !~ /^\d+$/
      flash.now[:alert] = 'JANコードは半角数字のみ入力してください。'
      render :show && return
    end
    base_url = "https://shopping.yahooapis.jp/ShoppingWebService/V3/itemSearch"
    url = "#{base_url}?appid=#{app_id}&jan_code=#{jan_code}"

    response = HTTParty.get(url, format: :plain)
    data = JSON.parse(response, symbolize_names: true)

    if data[:hits].present?
      @item = data[:hits].first
      render :show_item
    else
      @error_message = "商品情報が見つかりませんでした。"
      render :error_page
    end
  end

  def destroy
    if @analysis_session.destroy
      redirect_to user_items_path(current_user), notice: '分析セッションと関連するabc分析結果を削除しました。'
    else
      redirect_to user_items_path(current_user), alert: '分析セッションの削除に失敗しました。'
    end
  end

  private

  def set_analysis_session
    @analysis_session = current_user.analysis_sessions.find(params[:id])
  end
end
