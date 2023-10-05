require 'rails_helper'
require 'webmock/rspec'

RSpec.describe AnalysisSessionsController, type: :request do
  let(:user) { create(:user) }
  let(:analysis_session) { create(:analysis_session, user: user) }
  let!(:analysis_result) { create(:analysis_result, analysis_session: analysis_session) }  # 追加

  describe "GET #show" do
    before do
      sign_in user
      get analysis_session_path(analysis_session.id)
    end

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

    it "レスポンスに関連するanalysis_resultのsalesが含まれる" do
      expect(response.body).to include(analysis_result.sales.to_s)
    end
  end

  describe "DELETE #destroy" do
    before { sign_in user }

    it "analysis_sessionを削除するとリダイレクトされる" do
      delete analysis_session_path(analysis_session.id)
      expect(response).to have_http_status(:redirect)
    end

    it "analysis_sessionを削除するとデータが減少する" do
      expect {
        delete analysis_session_path(analysis_session.id)
      }.to change(AnalysisSession, :count).by(-1)
    end
  end

  describe "GET #show_item" do
    before { sign_in user }

    context "with valid JAN code" do
      let(:valid_jan_code) { "1234567890123" }
      let(:mocked_response_body) do
        {
          "hits": [
            {
              "name": "dummy_item",
              "url": "http://yahoo.co.jp/some_product",
              "image": {
                "medium": "http://path.to/image.jpg"
              }
            }
          ]
        }.to_json
      end

      before do
        stub_request(:get, "https://shopping.yahooapis.jp/ShoppingWebService/V3/itemSearch").
          with(query: { appid: ENV['YAHOO_APP_ID'], jan_code: valid_jan_code }).
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

      before do
        get show_item_analysis_session_path(analysis_session.id, jan_code: invalid_jan_code)
      end

      it "HTTPのステータスコードが200で返ってくる" do
        expect(response).to have_http_status(:success)
      end

      it "エラーメッセージが表示される" do
        expect(response.body).to include('JANコードは半角数字のみ入力してください。')
      end
    end
  end
end
