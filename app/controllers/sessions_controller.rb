class SessionsController < ApplicationController
before_action :get_user,          only: [:create]
before_action :wrong_credentials, only: [:create]
before_action :already_logged_in, only: [:create]
before_action :expired,           only: [:create]
  
  def new
    if logged_in?
      if current_license != "client"
        redirect_to users_url(current_user.id)
      else
        redirect_to current_user
      end
    end
  end
  
  def create
    login(@user)
    if logged_in?
      if current_license != "client"
        redirect_to users_url(current_user.id)
      else
        redirect_to current_user
      end
    else
      render :new
    end
  end
  
  def destroy
    logout if logged_in?
    redirect_to root_url
  end
  
  private

  def get_user
    @user = User.find_by(username: params[:session][:username])
  end

  def wrong_credentials
    if !@user || @user.password != params[:session][:password]

      flash.now[:danger] = 'Invalid username/password combination.'
      render :new
    end
  end

  def already_logged_in
    if @user.logged_in? && @user.license != "owner"

       flash.now[:danger] = 'Only one login at a time per account.'
       render :new
    end
  end
  
  def expired
    if !@user.expiration_date.nil? &&
      Date.today > @user.expiration_date

      flash.now[:danger] = 'Your account has expired!'
      render :new
    end
  end
    
end