require 'rails_helper'

RSpec.describe ReportsController, type: :request do
  let(:user) { create(:user) }
  let(:analysis_session) { create(:analysis_session, user: user) }
  let(:report) { create(:report, analysis_session: analysis_session) }
  before { sign_in user }

  describe "GET #new" do
    before { get new_analysis_session_report_path(analysis_session.id) }

    it "HTTPのステータスコードが200で返ってくる" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "有効なパラメータの場合" do
      let(:valid_params) do
        { report: attributes_for(:report) }
      end

      it "HTTPのステータスコードがリダイレクトで返ってくる" do
        post analysis_session_reports_path(analysis_session.id), params: valid_params
        expect(response).to have_http_status(:redirect)
      end

      it "レポートが新規作成される" do
        expect do
          post analysis_session_reports_path(analysis_session.id), params: valid_params
        end.to change(Report, :count).by(1)
      end

      it "新規作成された後、該当するレポートのページにリダイレクトされる" do
        post analysis_session_reports_path(analysis_session.id), params: valid_params
        expect(response).to redirect_to analysis_session_report_path(analysis_session, Report.last)
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) do
        { report: attributes_for(:report, overview: nil) }
      end

      it "HTTPのステータスコードが200で返ってくる" do
        post analysis_session_reports_path(analysis_session.id), params: invalid_params
        expect(response).to render_template(:new)
      end

      it "レポートが新規作成されない" do
        expect do
          post analysis_session_reports_path(analysis_session.id), params: invalid_params
        end.not_to change(Report, :count)
      end

      it "newテンプレートが再描画される" do
        post analysis_session_reports_path(analysis_session.id), params: invalid_params
        expect(response).to render_template :new
      end
    end
  end

  describe "GET #show" do
    before { get analysis_session_report_path(analysis_session.id, report.id) }

    it "HTTPのステータスコードが200で返ってくる" do
      expect(response).to have_http_status(:success)
    end

    it "レスポンスにレポートの概要が含まれる" do
      expect(response.body).to include(report.overview)
    end
  end

  describe "GET #edit" do
    before { get edit_analysis_session_report_path(analysis_session.id, report.id) }

    it "HTTPのステータスコードが200で返ってくる" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    context "有効なパラメータの場合" do
      let(:valid_params) do
        { report: attributes_for(:report, overview: "更新された概要") }
      end

      it "レポートが更新される" do
        patch analysis_session_report_path(analysis_session.id, report.id), params: valid_params
        expect(report.reload.overview).to eq "更新された概要"
      end

      it "更新後、該当するレポートのページにリダイレクトされる" do
        patch analysis_session_report_path(analysis_session.id, report.id), params: valid_params
        expect(response).to redirect_to analysis_session_report_path(analysis_session, report)
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) do
        { report: attributes_for(:report, overview: nil) }
      end

      it "レポートが更新されない" do
        patch analysis_session_report_path(analysis_session.id, report.id), params: invalid_params
        expect(report.reload.overview).not_to be_nil
      end

      it "editテンプレートが再描画される" do
        patch analysis_session_report_path(analysis_session.id, report.id), params: invalid_params
        expect(response).to render_template :edit
      end
    end
  end
end
