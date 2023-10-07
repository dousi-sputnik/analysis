require 'rails_helper'

RSpec.describe "Contacts", type: :request do
  let(:user) { create(:user) }
  let(:contact_params) { { contact: { name: "テストユーザ", content: "問い合わせ内容のテストです。" } } }

  before do
    sign_in user
  end

  describe "POST /contacts" do
    context "有効なデータを送信した場合" do
      it "問い合わせが正常に作成される" do
        expect {
          post contacts_path, params: contact_params
        }.to change(Contact, :count).by(1)
      end

      it "メールが送信される" do
        expect {
          post contacts_path, params: contact_params
        }.to change { ActionMailer::Base.deliveries.size }.by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to include("お問い合わせについて")
        expect(mail.to).to include(user.email)
      end

      it "完了ページやトップページなど、適切なページにリダイレクトされる" do
        post contacts_path, params: contact_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "無効なデータを送信した場合" do
      let(:invalid_contact_params) { { contact: { name: "", content: "" } } }

      it "問い合わせが作成されない" do
        expect {
          post contacts_path, params: invalid_contact_params
        }.not_to change(Contact, :count)
      end

      it "メールが送信されない" do
        expect {
          post contacts_path, params: invalid_contact_params
        }.not_to change { ActionMailer::Base.deliveries.size }
      end

      it "エラーが表示される" do
        post contacts_path, params: invalid_contact_params
        expect(response.body).to include("お名前を入力してください")
        expect(response.body).to include("お問合せ内容を入力してください")
      end
    end
  end
end
