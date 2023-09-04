class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @items = current_user.items.order(sales: :desc)
    @analysis_session = current_user.analysis_sessions.last
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
  
  def create_bulk
    analysis_session = current_user.analysis_sessions.new(title: params[:title], description: params[:description])
  
    unless analysis_session.save
      redirect_to new_user_item_path(current_user), alert: analysis_session.errors.full_messages.join(", ")
      return
    end
    
    bulk_data = params[:bulk_input]
    rows = bulk_data.split("\n")
    error_messages = []
  
    # トランザクションを使用
    Item.transaction do
      rows.each_with_index do |row, index|
        jan_code, product_name, sales_str = row.split("\t")
        sales = sales_str.to_i
        item = current_user.items.find_or_initialize_by(jan_code: jan_code)
        item.product_name = product_name
        item.sales = sales
        unless item.save
          error_messages << "行 #{index + 1} (JAN Code #{jan_code}): #{item.errors.full_messages.join(', ')}"
        end
      end

      raise ActiveRecord::Rollback unless error_messages.empty?
    end
  
    if error_messages.empty?
      redirect_to analysis_session_path(analysis_session), notice: "分析が完了しました。"
    else
      redirect_to new_user_item_path(current_user), alert: "次の商品の登録に失敗しました: #{error_messages.join(', ')}"
    end    
  end

  private

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def items_params
    params.require(:item).permit(:jan_code, :product_name, :sales)
  end
end
