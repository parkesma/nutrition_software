class SessionsController < ApplicationController
  
  def new
  end
  
  def create
    user = User.find_by(username: params[:session][:username])
    if user.logged_in?
      flash.now[:danger] = 'Only one login at a time per account'
      render 'new'
    else
      if Date.today > user.expiration_date
        flash.now[:danger] = 'Your account has expired!'
        render 'new'
      else
        if !user || user.password != params[:session][:password]
          flash.now[:danger] = 'Invalid username/password combination'
          render 'new'
        else
          login(user)
          current_user
          redirect_to root_url
        end
      end
    end
  end

  def destroy
    logout
    redirect_to root_url
  end
  
end
