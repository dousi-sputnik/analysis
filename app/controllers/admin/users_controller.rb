class Admin::UsersController < ApplicationController
  before_action :authenticate_admin

  def index
    @users = User.all
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, notice: 'ユーザーの削除に成功しました'
  end

  private

  def authenticate_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "権限がありません。"
    end
  end
end
