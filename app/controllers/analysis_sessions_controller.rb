class AnalysisSessionsController < ApplicationController
  def show
    @analysis_session = current_user.analysis_sessions.find(params[:id])
    @abc_items = @analysis_session.analysis_results
  
    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="abc_analysis.xlsx"'
        render xlsx: 'analysis', template: 'analysis_sessions/analysis'
      }
    end
  end
end

