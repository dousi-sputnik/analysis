class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_analysis_session
  before_action :set_report, only: [:show, :edit, :update, :destroy]

  def new
    @report = @analysis_session.reports.build
    @abc_items = @analysis_session.analysis_results
  end

  def create
    @report = @analysis_session.reports.build(report_params)
    if @report.save
      redirect_to analysis_session_report_path(@analysis_session, @report), notice: 'レポートが作成されました。'
    else
      render :new
    end
  end

  def show
    @report = @analysis_session.reports.find(params[:id])
    @abc_items = @analysis_session.analysis_results
    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="report_analysis.xlsx"'
        render xlsx: 'report', template: 'reports/report'
      end
    end
  end

  def edit
    @abc_items = @analysis_session.analysis_results
  end

  def update
    if @report.update(report_params)
      redirect_to analysis_session_report_path(@analysis_session, @report), notice: 'レポートが更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @report.destroy
    redirect_to analysis_session_path(@analysis_session), notice: 'レポートが削除されました。'
  end

  private

  def set_analysis_session
    @analysis_session = AnalysisSession.find(params[:analysis_session_id])
  end

  def report_params
    params.require(:report).permit(:content, :overview, :rank_a_trend, :rank_b_trend, :rank_c_trend)
  end

  def set_report
    @report = @analysis_session.reports.find(params[:id])
  end
end
