module SessionsHelper
	
  def login(user)
	  session[:user_id] = user.id
	  user.update_attribute("logged_in", true)
  end

  def current_user
  	@current_user || User.find_by(id: session[:user_id])
  end
  
  def logged_in?
  	!current_user.nil?
  end

  def current_license
    current_user.license if logged_in?
  end
  
  def logout
  	current_user.update_attribute("logged_in", false)
  	current_user.save
  	session.delete(:user_id)
  	session.delete(:focussed_id)
  	@current_user = nil
  	@focussed_user = nil
  end
  
  def focus(user)
    session[:focussed_id] = user.id
  end
  
  def focussed_user
    @focussed_user || User.find_by(id: session[:focussed_id])
  end
  
  def focussed?
    !focussed_user.nil?
  end
  
  def focussed_license
    focussed_user.license if focussed?
  end
  
  def master_date_check(date)
    if date.blank?
      return true
    else
      d, m, y = date.split '/'
		  if Date.valid_date? y.to_i, m.to_i, d.to_i
  			return true
		  else
    		flash[:danger] = "Invalid Date"
  		  redirect_to :back
  		  return false
		  end
		end
  end
  
end
