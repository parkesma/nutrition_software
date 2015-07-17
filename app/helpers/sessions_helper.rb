module SessionsHelper
	
  def login(user)
	  session[:user_id] = user.id
	  user.update_attribute("logged_in", true)
  end

  def current_user
  	@current_user ||= User.find_by(id: session[:user_id])
  	@license ||= @current_user.license
  end

  def logged_in?
  	!@current_user.nil?
  end
  
  def logout
  	session.delete(:user_id)
  	@current_user = nil
  	@license = nil
  end
  
end
