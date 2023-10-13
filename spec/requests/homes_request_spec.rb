require 'rails_helper'

RSpec.describe "Homes", type: :request do
  let(:user) { create(:user) }

  describe "GET /" do
    context "未ログインの場合" do
      it "ゲストログインボタンをクリックするとabc_analysisページに遷移する" do
      end
    end
  end
end
