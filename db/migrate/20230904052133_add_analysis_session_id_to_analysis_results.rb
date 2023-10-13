class AddAnalysisSessionIdToAnalysisResults < ActiveRecord::Migration[6.1]
  def change
    add_reference :analysis_results, :analysis_session, null: false, foreign_key: true
  end
end
