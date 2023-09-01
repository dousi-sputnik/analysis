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
      @abc_items.each do |item|
        current_user.analysis_results.create(
          jan_code: item[:jan_code],
          product_name: item[:product_name],
          sales: item[:sales],
          cumulative_sales: item[:cumulative_sales],
          cumulative_percentage: item[:cumulative_percentage],
          classification: item[:classification]
        )
      end
    end
    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disponsition'] = 'attachment; filename="abc_analysis.xlsx"'
      end
      format.pdf do
        render pdf: "abc_analysis",
               layout: 'pdf',
               template: 'items/analysis.pdf.erb',
               encoding: 'UTF-8'
      end
    end
  end

  def create_bulk
    bulk_data = params[:bulk_input]
    rows = bulk_data.split("\n")
    rows.each do |row|
      jan_code, product_name, sales = row.split("\t")
      current_user.items.create(jan_code: jan_code, product_name: product_name, sales: sales)
    end
    redirect_to analysis_path, notice: '商品情報が作成されました'
  end

  private

  def set_item
    @item = current_user.items.find(params { :id })
  end

  def items_params
    params.require(:item).permit(:jan_code, :product_name, :sales)
  end
end
