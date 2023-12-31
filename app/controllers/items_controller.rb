class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @items = current_user.items.order(sales: :desc)
    @analysis_sessions = current_user.analysis_sessions.order(created_at: :desc)
    @analysis_sessions_with_reports = current_user.analysis_sessions.includes(:reports)
  end

  def new
    @analysis_session = current_user.analysis_sessions.last
    @item = current_user.items.build(analysis_session: @analysis_session)

    unless @analysis_session
      flash.now[:alert] = '新しい商品を追加するための分析セッションが存在しません。商品登録後、分析セッションを作成してください。'
    end
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
    @analysis_session = current_user.analysis_sessions.build(title: params[:title], description: params[:description])

    if @analysis_session.invalid?
      @item = current_user.items.build(analysis_session: @analysis_session)
      handle_errors(@item, @analysis_session.errors.full_messages.join(", "))
      return
    end

    if params[:bulk_input].blank?
      @item ||= current_user.items.build(analysis_session: @analysis_session)
      handle_errors(@item, "Excelデータペーストエリアは空ではありませんか？")
      return
    end

    item_validator = Item.new(bulk_data: params[:bulk_input])
    item_validator.validate_bulk_data
    error_messages_for_bulk_data = item_validator.errors.full_messages
    unless error_messages_for_bulk_data.empty?
      @item ||= current_user.items.build(analysis_session: @analysis_session)
      handle_errors(@item, error_messages_for_bulk_data.join(", "))
      return
    end

    unless @analysis_session.save
      @item ||= current_user.items.build(analysis_session: @analysis_session)
      handle_errors(@item, @analysis_session.errors.full_messages.join(", "))
      return
    end

    error_messages = Item.create_from_bulk(params[:bulk_input], current_user, @analysis_session)

    if error_messages.empty?
      @analysis_session.analysis!
      @analysis_session.items.delete_all
      redirect_to analysis_session_path(@analysis_session), notice: "分析が完了しました。"
    else
      @item ||= current_user.items.build(analysis_session: @analysis_session)
      handle_errors(@item, "次の商品の登録に失敗しました: #{error_messages.join(', ')}")
    end
  end

  private

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def items_params
    params.require(:item).permit(:jan_code, :product_name, :sales)
  end

  def handle_errors(item, message)
    if item.nil?
      respond_to do |format|
        format.html { render :new, alert: message }
        format.js { render 'items/error', locals: { error_message: message }, status: :unprocessable_entity }
      end
    else
      item.errors.add(:base, message)
      respond_to do |format|
        format.html { render :new }
        format.js { render 'items/error', locals: { item: item }, status: :unprocessable_entity }
      end
    end
  end
end
