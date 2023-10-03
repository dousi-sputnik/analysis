require 'rails_helper'

RSpec.describe "Items", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /index" do
    context "ユーザーがanalysis_sessionsとitemsを持っている時" do
      let!(:analysis_session) { create(:analysis_session, user: user) }
      let!(:items) { create_list(:item, 5, user: user, analysis_session: analysis_session) }

      it "成功したレスポンスを返す" do
        get user_items_path(user)
        expect(response).to be_successful
      end

      it "ユーザーのABC分析のタイトル・説明・作成日を表示する" do
        get user_items_path(user)
        expect(response.body).to include(analysis_session.title)
        expect(response.body).to include(analysis_session.description)
        expect(response.body).to include(analysis_session.created_at.strftime("%Y/%m/%d %H:%M"))
        items.each do |item|
          expect(response.body).not_to include(item.product_name)
        end
      end
    end

    context "ユーザーがanalysis_sessionsを持っていない時" do
      it "成功したレスポンスを返す" do
        get user_items_path(user)
        expect(response).to be_successful
      end
    end
  end

  describe "GET /new" do
    context "ユーザーがanalysis_sessionsを持っている時" do
      let!(:analysis_session) { create(:analysis_session, user: user) }

      it "成功したレスポンスを返す" do
        get new_user_item_url(user_id: user.id)
        expect(response).to be_successful
      end
    end

    context "ユーザーがanalysis_sessionsを持っていない時" do
      it "アラートと共に成功したレスポンスを返す" do
        get new_user_item_url(user_id: user.id)
        expect(response).to be_successful
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST /create_bulk" do
    let(:valid_params) { { title: "title", description: "description", bulk_input: "123\tProduct\t10\n456\tProduct2\t20" } }

    context "入力が有効なとき" do
      it "新しいanalysis_sessionを作成する" do
        expect do
          post create_bulk_user_items_url(user_id: user.id), params: valid_params
        end.to change(AnalysisSession, :count).by(1)
      end

      it "作成したanalysis_sessionに遷移する" do
        post create_bulk_user_items_url(user_id: user.id), params: valid_params
        expect(response).to redirect_to(analysis_session_path(AnalysisSession.last))
      end
    end

    context "入力が無効なとき" do
      it "新しいanalysis_sessionを作成せず、newアクションに戻る" do
        expect do
          post create_bulk_user_items_url(user_id: user.id),
params: { title: "title", description: "description", bulk_input: "" }
        end.not_to change(AnalysisSession, :count)
        expect(response).to render_template(:new)
      end
    end
  end
end
