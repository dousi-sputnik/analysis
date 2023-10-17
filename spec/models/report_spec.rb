require 'rails_helper'

RSpec.describe Report, type: :model do
  let(:user) { create(:user) }
  let(:analysis_session) { create(:analysis_session, user: user) }
  let(:report) { build(:report, analysis_session: analysis_session) }

  describe 'validations' do
    subject { report }

    it '有効なfactoryを持つこと' do
      expect(subject).to be_valid
    end

    context 'overview validation' do
      it 'overviewがない場合は無効であること' do
        subject.overview = nil
        expect(subject).to be_invalid
      end

      it 'overviewが2000文字を超える場合は無効であること' do
        subject.overview = 'a' * 2001
        expect(subject).to be_invalid
      end
    end

    context 'rank_a_trend validation' do
      it 'rank_a_trendが2000文字を超える場合は無効であること' do
        subject.rank_a_trend = 'a' * 2001
        expect(subject).to be_invalid
      end
    end

    context 'rank_b_trend validation' do
      it 'rank_b_trendが2000文字を超える場合は無効であること' do
        subject.rank_b_trend = 'a' * 2001
        expect(subject).to be_invalid
      end
    end

    context 'rank_c_trend validation' do
      it 'rank_c_trendが2000文字を超える場合は無効であること' do
        subject.rank_c_trend = 'a' * 2001
        expect(subject).to be_invalid
      end
    end
  end
end
