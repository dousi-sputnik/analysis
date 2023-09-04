class AnalysisSessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_analysis_session, only: [:show, :destroy]

  def show
    @abc_items = @analysis_session.analysis_results
  
    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="abc_analysis.xlsx"'
        render xlsx: 'analysis', template: 'analysis_sessions/analysis'
      }
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

