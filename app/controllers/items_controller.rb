class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @items = current_user.items.order(sales: :desc)
  end

  def new
    @item = current_user.items.build
  end

  def create
    @item = current_user.items.build(item_params)
    if @item.save
      redirect_to user_items_path(current_user), notice: '商品登録に成功しました。'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to user_items_path(current_user), notice: '商品情報が更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @item.destroy
    redirect_to user_items_url, notice: '商品を削除しました。'
  end

  def abc_analysis
    @items = current_user.items.order(sales: :desc)
    total_sales = 
  end

  def create_bulk
    bulk_data = params[:bulk_input]
    rows = bulk_data.split("\n")
    rows.each do |row|
      jan_code, product_name, sales = row.split("\t")
      current_user.items.create(jan_code: jan_code, product_name: product_name, sales: sales)
    end
    redirect_to user_items_path(current_user), notice: '商品情報が作成されました'
  end

  private

  def set_item
    @item = current_user.items.find(params { :id })
  end

  def items_params
    params.require(:item).permit(:jan_code, :product_name, :sales)
  end
end
