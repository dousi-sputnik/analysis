require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    let(:user) { build(:user) }

    context "有効な情報が入力された場合" do
      it "ユーザーが正常に作成される" do
        expect(user).to be_valid
      end
    end

    context "メールアドレスが空の場合" do
      before { user.email = "" }

      it "ユーザーが無効になる" do
        expect(user).not_to be_valid
      end
    end

    context "重複したメールアドレスの場合" do
      before do
        create(:user, email: "duplicate@example.com")
        user.email = "duplicate@example.com"
      end

      it "ユーザーが無効になる" do
        expect(user).not_to be_valid
      end
    end

    context "パスワードが空の場合" do
      before { user.password = user.password_confirmation = "" }

      it "ユーザーが無効になる" do
        expect(user).not_to be_valid
      end
    end

    context "パスワードが6文字未満の場合" do
      before { user.password = user.password_confirmation = "Short" }

      it "ユーザーが無効になる" do
        expect(user).not_to be_valid
      end
    end

    context "パスワードが英大文字、小文字、数字をそれぞれ1文字以上含まない場合" do
      before { user.password = user.password_confirmation = "password" }

      it "ユーザーが無効になる" do
        expect(user).not_to be_valid
      end
    end

    context "passwordとpassword_confirmationが不一致の場合" do
      before { user.password = "Password1"; user.password_confirmation = "Password2" }

      it "ユーザーが無効になる" do
        expect(user).not_to be_valid
      end
    end
  end

  describe "関連付け" do
    let(:user) { create(:user) }

    it "ユーザーが削除されると、関連するanalysis_sessionsも削除される" do
      create(:analysis_session, user: user)
      expect { user.destroy }.to change(AnalysisSession, :count).by(-1)
    end
  end
end
