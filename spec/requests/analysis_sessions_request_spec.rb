require 'rails_helper'
require 'webmock/rspec'

RSpec.describe AnalysisSessionsController, type: :request do
  let(:user) { create(:user) }
  let(:analysis_session) { create(:analysis_session, user: user) }
  let!(:analysis_result) { create(:analysis_result, analysis_session: analysis_session) }
  before { sign_in user }

  describe "GET #show" do
    before { get analysis_session_path(analysis_session.id) }

    it "HTTPのステータスコードが200で返ってくる" do
      expect(response).to have_http_status(:success)
    end

    it "レスポンスにanalysis_sessionのタイトルが含まれる" do
      expect(response.body).to include(analysis_session.title)
    end

    it "レスポンスにanalysis_sessionの説明が含まれる" do
      expect(response.body).to include(analysis_session.description)
    end

    it "レスポンスに関連するanalysis_resultの商品名が含まれる" do
      expect(response.body).to include(analysis_result.product_name)
    end

    it "レスポンスに関連するanalysis_resultの売上高が含まれる" do
      expect(response.body).to include(analysis_result.sales.to_s)
    end
  end

  describe "DELETE #destroy" do
    it "analysis_sessionを削除するとリダイレクトされる" do
      delete analysis_session_path(analysis_session.id)
      expect(response).to have_http_status(:redirect)
    end

    it "analysis_sessionを削除するとデータが減少する" do
      expect do
        delete analysis_session_path(analysis_session.id)
      end.to change(AnalysisSession, :count).by(-1)
    end
  end

  describe "GET #show_item" do
    context "JANコードにAPI関連の情報を含む場合" do
      let(:valid_jan_code) { "1234567890123" }
      let(:mocked_response_body) do
        {
          "hits": [
            {
              "name": "dummy_item",
              "url": "http://yahoo.co.jp/some_product",
              "image": {
                "medium": "http://path.to/image.jpg",
              },
            },
          ],
        }.to_json
      end

      before do
        stub_request(:get, "https://shopping.yahooapis.jp/ShoppingWebService/V3/itemSearch").
          with(query: { appid: "dummy_app_id", jan_code: valid_jan_code }).
          to_return(body: mocked_response_body, status: 200, headers: { 'Content-Type' => 'application/json' })

        get show_item_analysis_session_path(analysis_session.id, jan_code: valid_jan_code)
      end

      it "HTTPのステータスコードが200で返ってくる" do
        expect(response).to have_http_status(:success)
      end

      it "商品情報がレスポンスに含まれる" do
        expect(response.body).to include("dummy_item")
      end

      it "YAHOOAPIのURLがレスポンスに含まれる" do
        expect(response.body).to include("http://yahoo.co.jp/some_product")
      end
    end

    context "with invalid JAN code" do
      let(:invalid_jan_code) { "abc" }

      before { get show_item_analysis_session_path(analysis_session.id, jan_code: invalid_jan_code) }

      it "HTTPのステータスコードが200で返ってくる" do
        expect(response).to have_http_status(:success)
      end

      it "エラーメッセージが表示される" do
        expect(response.body).to include('JANコードは半角数字のみ入力してください。')
      end
    end
  end
end
