module SessionsHelper
	
  def login(user)
	  session[:user_id] = user.id
	  user.update_attribute("logged_in", true)
  end

  def current_user
  	@current_user || User.find_by(id: session[:user_id])
  end
  
  def current_license
    current_user.license
  end

  def logged_in?
  	!current_user.nil?
  end
  
  def logout(user)
  	user.update_attribute("logged_in", false)
  	session.delete(:user_id)
  	@current_user = nil
  end

end
