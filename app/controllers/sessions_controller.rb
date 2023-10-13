class SessionsController < Devise::SessionsController
  def destroy
    if current_user.guest?
      guest_user = current_user
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      guest_user.destroy
      return redirect_to root_path if signed_out
    else
      super
    end
  end

  def new_guest
    o = [('a'..'z').to_a, ('A'..'Z').to_a, ('0'..'9').to_a]
    password = [o[0].sample, o[1].sample, o[2].sample].shuffle[0...6].join
    password << (0...3).map { o[rand(o.length)].sample }.join

    user = User.create!(
      guest: true,
      name: "ゲストユーザー",
      email: "guest_#{Time.zone.now.to_i}#{rand(100)}@example.com",
      password: password,
      password_confirmation: password
    )

    sign_in user
    redirect_to user_items_path(current_user), notice: 'ゲストユーザーとしてログインしました。'
  end
end
