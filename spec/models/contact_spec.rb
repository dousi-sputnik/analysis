require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe "validate" do
    let(:user) { create(:user) }
    let(:contact) { build(:contact, name: "テストユーザ", content: "問い合わせ内容のテストです。") }

    context "有効な情報が入力された場合" do
      it "問い合わせが正常に作成される" do
        expect(contact).to be_valid
      end
    end

    context "名前が空の場合" do
      before { contact.name = "" }

      it "問い合わせが無効になる" do
        expect(contact).not_to be_valid
        expect(contact.errors.messages[:name]).to include("を入力してください")
      end
    end

    context "問い合わせ内容が空の場合" do
      before { contact.content = "" }

      it "問い合わせが無効になる" do
        expect(contact).not_to be_valid
        expect(contact.errors.messages[:content]).to include("を入力してください")
      end
    end
  end
end
