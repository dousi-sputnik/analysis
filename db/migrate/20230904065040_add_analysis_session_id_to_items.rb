class AddAnalysisSessionIdToItems < ActiveRecord::Migration[6.1]
  def change
    add_reference :items, :analysis_session, null: false, foreign_key: true
  end
end
