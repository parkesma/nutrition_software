class UsersController < ApplicationController

	def show
		@user = User.find_by(id: params(:user_id))
	end
	
	def new
		@new_user = User.new
	end
	
	def create
		if current_license != "owner"
			@new_user = current_user.subs.new(user_params)
		else
			@new_user = User.new(user_params)
		end
		existing = User.find_by(first_name: user_params[:first_name], 
		                        last_name:  user_params[:last_name])
		if !existing.nil?
			flash[:danger] = "A user already exists with that first and last name."
			redirect_to 'edit'
		
		elsif current_license == "client"
			flash[:danger] = "You don't have authority to create new users."
			redirect_to 'root'
			
		elsif current_license   != "owner" &&
					@new_user.license != "client"
		
		  flash[:danger] = "Your license only allows you to create new clients."
		  redirect_to 'new'  
		  
		elsif current_license == "student" &&
		  		current_user.clients.length > 4
		      
		  flash[:danger] = "You have reaced your limit of new clients."
		  redirect_to 'root'

		elsif current_license != "owner" &&

					@new_user.license == "employee"

		  flash[:danger] = "Only program graduates may be added as employees or trainers."
		  redirect_to 'new'

		elsif @new_user.save

			redirect_to 'show'

		else

			flash[:danger] = "New user failed to save."
			redirect_to 'new'

		end				
	end

	def edit
		target = User.find(params[:id])
		if  target == current_user ||
			
				current_user.license == "owner" ||
				
				(current_license != "client" &&

					(target.license == "client" && 
					 current_user.clients.include?(target)) ||

					(target.license == "employee" &&
					 current_user.employees.include?(target))
				
				)

			render 'edit'

		else
			
			flash[:danger] = "You are not authorized to edit that account"
			redirect_to :root

		end	
	end
	
	def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
     flash[:success] = "Profile updated"
     redirect_to @user
    else
      render 'edit'
    end
	end

  def destroy
  	@target_user = User.find(params[:id])
  	if current_license == "owner"
    	@target_user.destroy
    	flash[:success] = "User deleted"
    	redirect_to :root
  	elsif current_license != "client" &&
  	
  				current_license != "employee" &&

					(@target_user.license == "client" && 
					 current_user.clients.include?(@target_user)) ||

					(@target_user.license == "employee" &&
					 current_user.employees.include?(@target_user))

  		target_relationship = Relationship.where(
  			"sub_id = ? AND sup_id = ?", 
  		   params[:id],   current_user.id
  		).pluck(:id)
			Relationship.destroy(target_relationship)


  		@target_user.update_attribute(:expiration_date, Date.yesterday)
  	
  		redirect_to :root
  	
  	else
  		
  		flash[:danger] = "You are not authorized to delete that account"
  		redirect_to :root
  		
  	end
  end
  
	private
	
		def user_params
			params.require(:user).permit(:creator_id, :username, :password, 
			                             :license, :first_name, :last_name, 
			                             :expiration)
		end
	
end