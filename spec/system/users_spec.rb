require 'rails_helper'

RSpec.describe "Users", type: :system do
  let(:user) { create(:user) }

  describe 'ログイン機能' do
    before do
      visit new_user_session_path
    end

    context '正しい情報を入力した場合' do
      it 'ログインに成功し、トップページへ遷移する' do
        fill_in 'user_email', with: user.email
        fill_in 'user_password', with: user.password
        click_button 'Log in'

        expect(current_path).to eq root_path
        expect(page).to have_content 'Logout'
      end
    end

    context '間違った情報を入力した場合' do
      it 'ログインに失敗し、ページが遷移しない' do
        fill_in 'user_email', with: 'wrong@example.com'
        fill_in 'user_password', with: 'wrongpassword'
        click_button 'Log in'

        expect(current_path).to eq new_user_session_path
        expect(page).to have_content('Log in')
      end
    end
  end

  describe 'ユーザー詳細ページ' do
    context 'ログインユーザーが自分のプロフィールを閲覧する場合' do
      before do
        login_as(user, scope: :user)
        visit user_path(user)
      end

      it 'ユーザーの名前とメールが表示されている' do
        expect(page).to have_content user.name
        expect(page).to have_content user.email
      end

      it 'プロフィール編集ボタンが存在する' do
        expect(page).to have_link 'プロフィール編集'
      end
    end
  end

  describe 'ユーザープロフィール編集機能' do
    before do
      login_as(user, scope: :user)
      visit edit_user_registration_path
    end

    context '正しい情報を入力した場合' do
      it 'ユーザー情報の更新に成功する' do
        fill_in 'user_name', with: '新しい名前'
        fill_in 'user_email', with: 'newemail@example.com'
        fill_in 'user_password', with: 'Newpassword1'
        fill_in 'user_password_confirmation', with: 'Newpassword1'
        fill_in 'user_current_password', with: user.password
        click_button 'Update'

        visit user_path(user)
        expect(page).to have_content '新しい名前'
        expect(page).to have_content 'newemail@example.com'
      end
    end

    context '間違った情報を入力した場合' do
      it 'ユーザー情報の更新に失敗し、エラーメッセージが表示される' do
        fill_in 'user_name', with: ''
        fill_in 'user_email', with: 'invalid_email'
        fill_in 'user_password', with: '123'
        fill_in 'user_password_confirmation', with: '1234'
        fill_in 'user_current_password', with: 'wrongcurrentpassword'
        click_button 'Update'

        expect(page).to have_content '名前を入力してください'
        expect(page).to have_content 'パスワードは6文字以上で入力してください パスワードは半角6~12文字英大文字・小文字・数字それぞれ１文字以上含む必要があります パスワード（確認用）が一致していません'
      end
    end
  end

  describe 'ユーザー登録機能' do
    before do
      visit new_user_registration_path
    end

    context '正しい情報を入力した場合' do
      it 'ユーザー登録に成功し、トップページへ遷移する' do
        fill_in 'user_name', with: '新規ユーザー'
        fill_in 'user_email', with: 'newuser@example.com'
        fill_in 'user_password', with: 'Password1'
        fill_in 'user_password_confirmation', with: 'Password1'
        click_button 'Sign up'

        expect(current_path).to eq root_path
        expect(page).to have_content 'Logout'
      end
    end

    context '間違った情報を入力した場合' do
      it 'ユーザー登録に失敗し、エラーメッセージが表示される' do
        fill_in 'user_name', with: ''
        fill_in 'user_email', with: 'invalid@email'
        fill_in 'user_password', with: '123'
        fill_in 'user_password_confirmation', with: '1234'
        click_button 'Sign up'

        expect(page).to have_content '名前を入力してください'
        expect(page).to have_content 'パスワードは6文字以上で入力してください パスワードは半角6~12文字英大文字・小文字・数字それぞれ１文字以上含む必要があります パスワード（確認用）が一致していません'
      end
    end
  end

  describe 'パスワード変更申請機能' do
    before do
      ActionMailer::Base.deliveries.clear
      visit new_user_password_path
    end

    it 'メールによるパスワード変更の手順を完了する' do
      fill_in 'user_email', with: user.email
      click_button 'パスワードの変更を申請する'

      expect(ActionMailer::Base.deliveries.size).to eq 1
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to include user.email

      body = mail.body.to_s
      url = body.match(/href="([^"]+)"/)[1]
      visit url

      new_password = "New123"
      fill_in 'user_password', with: new_password
      fill_in 'user_password_confirmation', with: new_password
      click_button 'Change my password'

      visit new_user_session_path
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: new_password
      click_button 'Log in'
      expect(current_path).to eq root_path
      expect(page).to have_content 'Logout'
    end
  end
end
