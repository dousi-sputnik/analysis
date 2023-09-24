class SessionsController < Devise::SessionsController
  def new_guest
    sign_in guest_user
    redirect_to items_new_path, notice: 'ゲストユーザーとしてログインしました。'
  end
end
