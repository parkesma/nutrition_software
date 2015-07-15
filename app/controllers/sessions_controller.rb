class SessionsController < ApplicationController
  
  def new
  end
  
  def create
    user = User.find_by(username: params[:session][:username])
    if user
      login(user)
      current_user
      redirect_to root_url
    else
      flash.now[:danger] = 'Invalid username/password combination'
      render 'new'
    end
  end

  def destroy
    logout
    redirect_to root_url
  end
  
end
