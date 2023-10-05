require 'rails_helper'

RSpec.describe AnalysisSession, type: :model do
  describe 'validations' do
    let(:user) { create(:user) }
    subject { build(:analysis_session, user: user) }

    it '有効なファクトリを持つこと' do
      expect(subject).to be_valid
    end

    context 'title' do
      it 'titleがない場合は無効であること' do
        subject.title = nil
        expect(subject).to be_invalid
      end

      it 'titleが50文字を超える場合は無効であること' do
        subject.title = 'a' * 51
        expect(subject).to be_invalid
      end
    end

    context 'description' do
      it 'descriptionがない場合は無効であること' do
        subject.description = nil
        expect(subject).to be_invalid
      end

      it 'descriptionが500文字を超える場合は無効であること' do
        subject.description = 'a' * 501
        expect(subject).to be_invalid
      end
    end
  end

  describe 'analysis!' do
    let(:user) { create(:user) }
    let(:analysis_session) { create(:analysis_session, user: user) }

    before do
      create(:item, sales: 100, jan_code: '1234567890123', analysis_session: analysis_session, product_name: "商品A")
      create(:item, sales: 50, jan_code: '1234567890124', analysis_session: analysis_session, product_name: "商品B")
      create(:item, sales: 25, jan_code: '1234567890125', analysis_session: analysis_session, product_name: "商品C")
    end

    it 'ABC分析が正しく実行されること' do
      analysis_session.analysis!
      results = analysis_session.analysis_results.order(:jan_code)

      expect(results[0].classification).to eq('A')
      expect(results[1].classification).to eq('A')
      expect(results[2].classification).to eq('B')
    end
  end

  describe 'callbacks' do
    let(:user) { create(:user) }

    context '保存した分析セッションの数がUser::MAX_ANALYSIS_SESSIONSを超える場合' do
      before do
        User::MAX_ANALYSIS_SESSIONS.times { create(:analysis_session, user: user) }
      end

      it '最も古い分析セッションが削除されること' do
        oldest_session = user.analysis_sessions.first
        create(:analysis_session, user: user)
        expect(user.analysis_sessions.reload).not_to include(oldest_session)
      end
    end
  end
end
