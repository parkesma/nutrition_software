class UsersController < ApplicationController

	def index
		@current_user = current_user
		if current_license == "owner"
			@owners    = User.where("license = ?", "owner")
			@employers = User.where("license = ?", "employer")
			@trainers  = User.where("license = ?", "trainer")
			@students  = User.where("license = ? OR license = ?", 
			                        "student",     "unlimited student")

			subs = Relationship.all.pluck(:sub_id)
			@orphans = User.where("id NOT IN (?) AND (license = ? OR license = ? OR license is null)",
			                       subs,             "employee",    "client")

		elsif current_license == "employer"
			@clients    = @current_user.clients
			@employees  = @current_user.employees
		elsif current_license != "client"
			@clients    = @current_user.clients
		end
	end
	
	def show
		@user = User.find_by(id: params[:id])
		focus(@user) if current_license != "client"
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
		capitalize_params
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

			else
				flash[:danger] = "New user failed to save."
				redirect_to new_user_url
				
			end
			
			redirect_to edit_user_url(@new_user.id)
			
		end
	end
	
	def edit
		@user = User.find(params[:id])
		if  @user == current_user ||
				
				current_user.license == "owner" ||
				
				(current_license != "client" &&
					
					(@user.license == "client" && 
					 current_user.clients.include?(@user)) ||
					
					(@user.license == "employee" &&
					 current_user.employees.include?(@user))
					
				)
			
			@possible_trainers  = User.where("license = ? OR license = ?",
			                                 "employer",    "trainer")
			
			@possible_employers = User.where("license = ?", "employer")
		else
			
			flash[:danger] = "You are not authorized to edit that account"
			redirect_to root_url

		end	
	end
	
	def update
		capitalize_params
    @user = User.find(params[:id])
		new_date = "(#{user_params["expiration_date(3i)"].to_i}, #{user_params["expiration_date(2i)"].to_i}, #{user_params["expiration_date(1i)"].to_i})"
		user_params[:expiration_date] = new_date
		@user.password = params[:reset] if !params[:reset].blank?

    if @user.update_attributes(user_params)
    	flash[:success] = "Profile updated"
    	redirect_to @user

    else
    	flash.now[:danger] = "Changes failed to save"
      render :edit

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
  end
  
  def find
		@listings = User.where(
			"(expiration_date is null OR expiration_date>?) AND (license=? OR license=?)",
			  													 Date.today,             "trainer",   "employer")

  	if !search_params[:city].blank?
  		@listings = @listings.where("work_city=?", search_params[:city].capitalize)
  	end	

  	if !search_params[:state].blank?
  		@listings = @listings.where("work_state=?", unabbreviate(search_params[:state]))
  	end
  	
  	if !search_params[:zip].blank?
  		@listings = @listings.where("work_zip=?", search_params[:zip])
  	end

  end
	
	def basic_info
		@user = focussed_user
	end
	
	def update_basic_info
		@user = focussed_user
    
		if @user.update_attributes(basic_info_params)
    	flash[:success] = "Basic info updated"

    else
    	flash[:danger] = "Changes failed to save"

		end
		redirect_to :basic_info
	end
	
	private
	
		def user_params
			params.require(:user).permit(
				:creator_id, :username, :password, :license, :first_name, 
				:last_name, :logged_in, :expiration_date_string,

				:home_address_1, :home_address_2, :home_csz_string, 
				:home_country, :work_address_1, :work_address_2,
				:work_csz_string, :work_country, :email, :home_phone, 
				:mobile_phone, :work_phone, :other_phone,
				
				:company, :website1, :website2
			)
		end
		
		def basic_info_params
			params.require(:user).permit(
				:starting_date_string, :gender, :resting_heart_rate, :present_weight, 
				:clothing, :present_body_fat, :height, :date_of_birth_string, 
				:desired_weight, :desired_body_fat, :measured_metabolic_rate, 
				:activity_index
			)
		end
		
		def search_params
			params.require(:search).permit(:city, :state, :zip)
		end

		def capitalize_params
			to_capitalize = [:first_name, :last_name, :home_city, :home_state, 
				:home_country, :work_city, :work_state, :work_country, :company]
				
			to_capitalize.each do |field|
				user_params[field] = user_params[field].capitalize if 
					!user_params[field].blank?
			end
		end
		
		def unabbreviate(state)
			states = [
				{'AL'=>'Alabama'},
				{'AK'=>'Alaska'},
				{'AZ'=>'Arizona'},
				{'AR'=>'Arkansas'},
				{'CA'=>'California'},
				{'CO'=>'Colorado'},
				{'CT'=>'Connecticut'},
				{'DE'=>'Delaware'},	
				{'FL'=>'Florida'},
				{'GA'=>'Georgia'},
				{'HI'=>'Hawaii'},	
				{'ID'=>'Idaho'},
				{'IL'=>'Illinois'},
				{'IN'=>'Indiana'},
				{'KS'=>'Kansas'},
				{'KY'=>'Kentucky'},
				{'LA'=>'Louisiana'},
				{'ME'=>'Maine'},
				{'MD'=>'Maryland'},
				{'MA'=>'Massachusetts'},
				{'MI'=>'Michigan'},
				{'MN'=>'Minnesota'},
				{'MS'=>'Mississippi'},
				{'MO'=>'Missouri'},	
				{'MT'=>'Montana'},
				{'NE'=>'Nebraska'},
				{'NV'=>'Nevada'},
				{'NH'=>'New Hampshire'},
				{'NJ'=>'New Jersey'},
				{'NM'=>'New Mexico'},	
				{'NY'=>'New York'},
				{'NC'=>'North Carolina'},
				{'ND'=>'North Dakota'},
				{'OH'=>'Ohio'},
				{'OK'=>'Oklahoma'},
				{'OR'=>'Oregon'},
				{'PA'=>'Pennsylvania'},
				{'RI'=>'Rhode Island'},
				{'SC'=>'South Carolina'},
				{'SD'=>'South Dakota'},
				{'TN'=>'Tennessee'},
				{'TX'=>'Texas'},
				{'UT'=>'Utah'},
				{'VT'=>'Vermont'},
				{'VA'=>'Virginia'},
				{'WA'=>'Washington'},
				{'WV'=>'West Virginia'},
				{'WI'=>'Wisconsin'},
				{'WY'=>'Wyoming'}
			]
		
			if state.size == 2
				states[state]
			else
				state.capitalized
			end
		
		end
		
end