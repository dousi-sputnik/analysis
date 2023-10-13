class CreateAnalysisSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :analysis_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
