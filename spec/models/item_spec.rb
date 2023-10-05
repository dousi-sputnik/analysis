require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:user) { create(:user) }
  let(:analysis_session) { create(:analysis_session, user: user) }

  describe 'バリデーション' do
    context '入力データが有効なデータの場合' do
      it '有効なこと' do
        item = build(:item, user: user, analysis_session: analysis_session)
        expect(item).to be_valid
      end
    end

    context 'JANコードが空の場合' do
      it '無効であること' do
        item = build(:item, jan_code: nil, user: user, analysis_session: analysis_session)
        item.valid?
        expect(item.errors[:jan_code]).to include("を入力してください")
      end
    end

    context '商品名が空の場合' do
      it '無効であること' do
        item = build(:item, product_name: nil, user: user, analysis_session: analysis_session)
        item.valid?
        expect(item.errors[:product_name]).to include("を入力してください")
      end
    end

    context '販売数が空の場合' do
      it '無効であること' do
        item = build(:item, sales: nil, user: user, analysis_session: analysis_session)
        item.valid?
        expect(item.errors[:sales]).to include("を入力してください", "は数値で入力してください")
      end
    end

    context '販売数が0未満の場合' do
      it '無効であること' do
        item = build(:item, sales: -1, user: user, analysis_session: analysis_session)
        item.valid?
        expect(item.errors[:sales]).to include("は0以上の値にしてください")
      end
    end
  end

  describe '#validate_bulk_data' do
    context 'bulk_dataが501行の場合' do
      it 'エラーメッセージを返すこと' do
        item = build(:item, user: user, analysis_session: analysis_session)
        item.bulk_data = "1\t2\t3\n" * 501
        item.valid?
        expect(item.errors[:bulk_data]).to include("は最低1行、最大500行までです。")
      end
    end

    context 'bulk_dataの各行が3つのタブ区切りデータを持たない場合' do
      it 'エラーメッセージを返すこと' do
        item = build(:item, user: user, analysis_session: analysis_session)
        item.bulk_data = "1\t2\n"
        item.valid?
        expect(item.errors[:bulk_data]).to include("の行 1 はデータが不正です。")
      end
    end
  end

  describe '.create_from_bulk' do
    context 'bulk_dataが空の場合' do
      it 'エラーメッセージを返すこと' do
        errors = Item.create_from_bulk("", user, analysis_session)
        expect(errors).to eq ["Excelデータペーストエリアは空ではありませんか？"]
      end
    end

    context 'bulk_dataの各行が3つのタブ区切りデータを持つ場合' do
      it '正しくItemを作成すること' do
        bulk_data = "4900000000001\t商品A\t1000\n4900000000002\t商品B\t2000"
        expect {
          Item.create_from_bulk(bulk_data, user, analysis_session)
        }.to change(Item, :count).by(2)
      end
    end
  
    context '不正なデータが含まれる場合' do
      it 'エラーメッセージを返すこと' do
        bulk_data = "4900000000001\t商品A\t1000\n4900000000002\t商品B"
        errors = Item.create_from_bulk(bulk_data, user, analysis_session)
        expect(errors).to include("行 2: データが不正です。")
      end
    end
  
    context '既存のJANコードが含まれる場合' do
      let!(:existing_item) { create(:item, jan_code: "4900000000001", user: user, analysis_session: analysis_session) }
  
      it '更新されること' do
        bulk_data = "4900000000001\t商品C\t1500"
        Item.create_from_bulk(bulk_data, user, analysis_session)
        existing_item.reload
        expect(existing_item.product_name).to eq("商品C")
        expect(existing_item.sales).to eq(1500)
      end
    end
  
    context '保存に失敗するデータが含まれる場合' do
      it 'エラーメッセージを返すこと' do
        bulk_data = "4900000000001\t\t1000"
        errors = Item.create_from_bulk(bulk_data, user, analysis_session)
        expect(errors).to include("行 1 (JAN Code 4900000000001): Product nameを入力してください")
      end
    end
  end
end
