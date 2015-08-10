class SessionsController < ApplicationController
before_action :get_user,          only: [:create, :destroy]
before_action :wrong_credentials, only: [:create]
before_action :already_logged_in, only: [:create]
before_action :expired,           only: [:create]
  
  def new
  end
  
  def create
    login(@user)
    redirect_to root_url
  end
  
  def destroy
    logout(@user)
    redirect_to root_url
  end
  
  private

  def get_user
    @user = User.find_by(username: params[:session][:username])
  end

  def wrong_credentials
    if !@user || @user.password != params[:session][:password]

      flash[:danger] = 'Invalid username/password combination'
      redirect_to 'new'
    end
  end

  def already_logged_in
    if @user.logged_in?

       flash[:danger] = 'Only one login at a time per account'
       redirect_to 'new'
    end
  end
  
  def expired
    if !@user.expiration_date.nil? &&
      Date.today > @user.expiration_date

      flash[:danger] = 'Your account has expired!'
      redirect_to 'new'
    end
  end
    
end