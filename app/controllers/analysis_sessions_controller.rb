class AnalysisSessionsController < ApplicationController
  def show
    @analysis_session = AnalysisSession.find(params[:id])
    @results = @analysis_session.analysis_results
  end
end
