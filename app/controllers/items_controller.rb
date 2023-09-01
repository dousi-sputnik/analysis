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

  def analysis
    @items = current_user.items.order(sales: :desc)
    total_sales = @items.sum(:sales)
    cumulative_sales = 0
    @abc_items = []
    
    @items.each do |item|
      cumulative_sales += item.sales
      cumulative_percentage = (cumulative_sales.to_f / total_sales) * 100
      if cumulative_percentage <= 70
        item_classification = "A"
      elsif cumulative_percentage <= 90
        item_classification = "B"
      else
        item_classification = "C"
      end
      
      # ここで@abc_itemsにデータを追加します。
      @abc_items << {
        jan_code: item.jan_code,
        product_name: item.product_name,
        sales: item.sales,
        cumulative_sales: cumulative_sales,
        cumulative_percentage: cumulative_percentage,
        classification: item_classification
      }
    end
    
    # @abc_itemsに基づいてanalysis_resultsテーブルにデータを保存します。
    @abc_items.each do |item_data|
      current_user.analysis_results.create(item_data)
    end
    
    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disponsition'] = 'attachment; filename="abc_analysis.xlsx"'
      end
      format.pdf do
        render pdf: "analysis",
               layout: false,
               template: 'items/analysis_pdf.erb',
               encoding: 'UTF-8'
      end
    end
  end
  

  def create_bulk
    bulk_data = params[:bulk_input]
    rows = bulk_data.split("\n")
    error_messages = []
    success_count = 0
  
    # トランザクションを使用
    Item.transaction do
      rows.each_with_index do |row, index|
        jan_code, product_name, sales_str = row.split("\t") # Split into three variables
        sales = sales_str.to_i # Convert sales string to integer
        item = current_user.items.find_or_initialize_by(jan_code: jan_code)
        item.product_name = product_name
        item.sales = sales
        if item.save
          success_count += 1
        else
          Rails.logger.error("Failed to save item with JAN Code: #{jan_code}. Errors: #{item.errors.full_messages.join(', ')}")
          error_messages << "行 #{index + 1} (JAN Code #{jan_code}): #{item.errors.full_messages.join(', ')}"
        end
      end
  
      # すべての保存が成功していない場合、トランザクションをロールバック
      raise ActiveRecord::Rollback unless error_messages.empty?
    end
  
    if error_messages.empty?
      redirect_to analysis_path, notice: "#{success_count} 商品情報が作成されました"
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
