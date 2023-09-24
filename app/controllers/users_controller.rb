class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :correct_user, only: [:show, :edit, :update]

  def show
    @analysis_results = current_user.analysis_results.order(created_at: :desc)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'ユーザーの更新に成功しました'
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def correct_user
    unless @user == current_user
      redirect_to root_url, alert: '権限がありません。'
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
