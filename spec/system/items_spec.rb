require 'rails_helper'

RSpec.describe "Items", type: :system do
  let(:user) { create(:user) }
  let!(:analysis_session) { create(:analysis_session, user: user) }
  let!(:items) { create_list(:item, 5, user: user, analysis_session: analysis_session) }
  let(:valid_bulk_input) { items.map { |item| "#{item.jan_code}\t#{item.product_name}\t#{item.sales}" }.join("\n") }
  let!(:analysis_results) do 
    items.map do |item|
      create(:analysis_result, analysis_session: analysis_session, jan_code: item.jan_code)
    end
  end

  before do
    login_as(user, scope: :user)
  end

  describe 'Items Analysis Flow' do
    context 'ItemからAnalysisの流れの場合' do
      it 'Itemのindexアクションからnewアクション、その後create_bulkアクションを経由してanalysis_sessionコントローラのshowアクションへ。最後にItem#indexアクションへ戻る' do
        visit user_items_path(user)
        expect(page).to have_content("タイトル")

        click_link 'ABC分析開始'
        expect(current_path).to eq new_user_item_path(user)

        fill_in 'title', with: 'テストタイトル'
        fill_in 'description', with: 'これはテストです。'
        fill_in 'bulk_input', with: valid_bulk_input

        click_button 'ABC分析表を出力'
        expect(current_path).to eq analysis_session_path(AnalysisSession.last.id)

        visit analysis_session_path(AnalysisSession.last.id)
        expect(page).to have_content('テストタイトル')
        expect(page).to have_content('これはテストです。')
        
        analysis_results.each do |result|
          expect(page).to have_content(result.jan_code)
          expect(page).to have_content(result.product_name)
          expect(page).to have_content(result.sales)
        end
        visit user_items_path(user)
        expect(page).to have_content('テストタイトル')
        expect(page).to have_content(AnalysisSession.last.created_at.strftime('%Y/%m/%d'))
        expect(page).to have_content(AnalysisSession.last.description)
      end
    end
  end
end
