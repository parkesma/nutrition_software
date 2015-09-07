class UsersController < ApplicationController

	def index
		@current_user = current_user
		if current_license == "owner"
			@owners    = User.where("license = ?", "owner")
			@employers = User.where("license = ?", "employer")
			@trainers  = User.where("license = ?", "CFNS")
			@students  = User.where("license = ? OR license = ?", 
			                        "student",     "unlimited student")

			subs = Relationship.all.pluck(:sub_id)
			if subs.length == 0
				@orphans = User.where("license = ? OR license = ? OR license is null",
			  	                     "employee",    "client")
			else
				@orphans = User.where("id NOT IN (?) AND (license = ? OR license = ? OR license is null)",
			  	                     subs,             "employee",    "client")
			end

		elsif current_license == "employer"
			@clients    = @current_user.clients
			@employees  = @current_user.employees
		elsif current_license != "client"
			@clients    = @current_user.clients
		end
	end
	
	def show
		@user = User.find_by(id: params[:id])
		focus(@user) if @user.license == "client"
	end
	
	def new
		@current_license = current_license
		@new_user = User.new

		if @current_license == "employer"
			flash.now[:success] = 'If you are adding an employee, simply enter his/her 
			existing username and select "employee" under license.'
		end
	end
	
	def create
		existing = User.find_by(first_name: user_params[:first_name], 
		                        last_name:  user_params[:last_name])
		if !existing.nil?
			flash[:danger] = "A user already exists with that first and last name."
			redirect_to new_user_url
			
		elsif current_license == "client"
			flash[:danger] = "You don't have authority to create new users."
			redirect_to root_url
			
		elsif current_license == "employer" &&
					user_params[:license] == "employee"
		
			existing = User.find_by(username: user_params[:username])

			if existing.graduated?
				@new_relationship = Relationship.create(sup_id: current_user.id,
																						 		sub_id: existing.id)
				existing.update_attribute(:license, "employee")
				redirect_to edit_user_url(existing.id)
			
			else
		  	flash[:danger] = "Only program graduates may be added as employees."
		  	redirect_to new_user_url				
			end
				 
		elsif current_license == "student" &&
		  		current_user.clients.length > 4
		      
		  flash[:danger] = "You have reaced your limit of new clients."
		  redirect_to root_url

		elsif current_license != "owner" &&
					user_params[:license] != "client"
		
	  	flash[:danger] = "Your license only allows you to create new clients."
	  	redirect_to new_user_url

		else
			@new_user = User.new(user_params)
			
			if @new_user.save
				if current_license != "owner"
					@new_relationship = Relationship.create(sup_id: current_user.id,
																							 		sub_id: @new_user.id)
				
				end
				redirect_to edit_user_url(@new_user.id)

			else
				flash[:danger] = "New user failed to save."
				redirect_to new_user_url
				
			end			
		end
	end
	
	def edit
		@states = states
		@user = User.find_by(id: params[:id])
		if authorized_to_edit(@user)
			
			@possible_cfns = User.where("license = ? OR license = ?",
	                     "employer",    "CFNS").order(:last_name)
			
			@possible_employers = User.where("license = ?", 
														"employer").order(:last_name)
		else
			
			flash[:danger] = "You are not authorized to edit that account"
			redirect_to root_url

		end	
	end
	
	def update
   	@user = User.find(params[:id])
		if authorized_to_edit(@user)

			@user.password = params[:reset] if !params[:reset].blank?

			if !params[:cfns].blank?
				reset_relationship(@user.id, params[:cfns])
			elsif !params[:employer].blank?
				reset_relationship(@user.id, params[:employer])
			end

			if @user.update_attributes(user_params)
	    	flash[:success] = "Profile updated"
   			redirect_to @user

   		else
	    	flash.now[:danger] = "Changes failed to save"
     		render :edit
			end
		
		else
			flash[:danger] = "You are not authorized to edit that account"
			redirect_to root_url
			
		end
	end

  def destroy
  	@target_user = User.find(params[:id])
  	if current_license == "owner"
    	@target_user.destroy
    	flash[:success] = "User deleted"
    	redirect_to root_url
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
  	
  		redirect_to root_url
  	
  	else
  		
  		flash[:danger] = "You are not authorized to delete that account"
  		redirect_to root_url
  		
  	end
  end
  
  def search
  	@states = states
  end
  
  def find
		@listings = User.where(
			"(expiration_date is null OR expiration_date>?) AND (license=? OR license=?)",
			  													 Date.today,             "CFNS",   "employer")

  	if !search_params[:city].blank?
  		@listings = @listings.where("work_city=?", search_params[:city].capitalize)
  	end	

  	if !search_params[:state].blank?
  		@listings = @listings.where("work_state=?", search_params[:state])
  	end
  	
  	if !search_params[:zip].blank?
  		@listings = @listings.where("work_zip=?", search_params[:zip])
  	end

  end
	
	def basic_info
		@user = focussed_user
	end
	
	def update_basic_info
		if current_license == "client"
			flash[:danger] = "You are not authorized to make these changes"
			
		else
			@user = focussed_user
    
			if @user.update_attributes(basic_info_params)
    		flash[:success] = "Basic info updated"

    	else
	    	flash[:danger] = "Changes failed to save"

			end
		end
		redirect_to :basic_info
	end
	
	private
	
		def user_params
			params.require(:user).permit(
				:creator_id, :username, :password, :license, :first_name, 
				:last_name, :logged_in, :starting_date_string, 
				:expiration_date_string, :cfns, :employer,

				:home_address_1, :home_address_2, :home_city, :home_state,
				:home_zip, :home_country, :work_address_1, 
				:work_address_2, :work_city, :work_state, :work_zip,
				:work_country, :email, :home_phone, :mobile_phone, 
				:work_phone, :other_phone,
				
				:company, :website1, :website2
			)
		end
		
		def basic_info_params
			params.require(:user).permit(
				:gender, :resting_heart_rate, :present_weight, 
				:clothing, :present_body_fat, :height, 
				:date_of_birth_string, :desired_weight, 
				:desired_body_fat, :measured_metabolic_rate, 
				:activity_index
			)
		end
		
		def search_params
			params.require(:search).permit(:city, :state, :zip)
		end

		def reset_relationship(subid, supid)
			
			Relationship.where("sub_id = ?", subid).each do |r|
				r.delete
			end
			
			Relationship.create(sub_id: subid, sup_id: supid)
		end
	
		def authorized_to_edit(user)
			user == current_user ||
				
			current_user.license == "owner" ||
				
			(current_license != "client" &&
					
				(user.license == "client" && 
				 current_user.clients.include?(user)) ||
					
				(user.license == "employee" &&
				 current_user.employees.include?(user))
					
			)
		end
		
		def states
			['AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI',
  		'ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI',
  		'MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC',
  		'ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT',
  		'VT','VA','WA','WV','WI','WY']
		end
		
end