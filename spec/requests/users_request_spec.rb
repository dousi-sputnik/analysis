require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }

  describe "GET /users/sign_up" do
    it "新規登録ページの表示に成功する" do
      get new_user_registration_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /users" do
    context "有効なデータを送信した場合" do
      let(:valid_params) { { user: { email: "test@example.com", password: "Password1", password_confirmation: "password" } } }

      it "ユーザーを新規登録できる" do
        expect {
          post user_registration_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "ユーザーのプロフィールページにリダイレクトされる" do
        post user_registration_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "無効なデータを送信した場合" do
      let(:invalid_params) { { user: { email: "", password: "password", password_confirmation: "password" } } }

      it "ユーザーを新規登録できない" do
        expect {
          post user_registration_path, params: invalid_params
        }.not_to change(User, :count)
      end

      it "エラーが表示される" do
        post user_registration_path, params: invalid_params
        expect(response.body).to include("エラーが発生したため ユーザー は保存されませんでした。")
      end
    end
  end

  describe "GET /users/sign_in" do
    it "ログインページの表示に成功する" do
      get new_user_session_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /users/sign_in" do
    context "有効な情報でログインした場合" do
      before do
        post user_session_path, params: { user: { email: user.email, password: user.password } }
      end

      it "ログインに成功する" do
        expect(response).to redirect_to(root_path)
        expect(controller.current_user).to eq(user)
      end
    end

    context "無効な情報でログインした場合" do
      before do
        post user_session_path, params: { user: { email: user.email, password: "wrong_password" } }
      end

      it "ログインに失敗する" do
        expect(response).to have_http_status(422)
        expect(controller.current_user).to be_nil
      end
    end
  end

  describe "GET /users/edit" do
    context "ログイン済みの場合" do
      before do
        sign_in user
        get edit_user_registration_path
      end

      it "プロフィール編集ページの表示に成功する" do
        expect(response).to have_http_status(:success)
      end
    end

    context "未ログインの場合" do
      before { get edit_user_registration_path }

      it "ログインページにリダイレクトされる" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
