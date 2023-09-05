class UpdateJanCodeUniqueness < ActiveRecord::Migration[6.1]
  def change
    remove_index :items, :jan_code
    if index_exists?(:items, [:jan_code, :user_id])
      remove_index :items, [:jan_code, :user_id]
    end
    add_index :items, [:jan_code, :analysis_session_id], unique: true
  end
end
