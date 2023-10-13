class RemoveUserIdFromAnalysisResults < ActiveRecord::Migration[6.1]
  def change
    remove_column :analysis_results, :user_id, :bigint
  end
end
