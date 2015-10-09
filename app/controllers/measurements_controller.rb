class MeasurementsController < ApplicationController
	before_action :date_check, only: [:create, :update]

	def index
		if authorized_to_see(focussed_user)
			@measurement = Measurement.new
			@measurements = focussed_user.measurements.order(
				"created_at DESC")
		else
			flash[:danger] = "You are not authorized to view measurements for this client"
			redirect_to root_path
		end
	end
	
	def create
		if authorized_to_edit(focussed_user)
      
      @measurement = focussed_user.measurements.build(
      								measurement_params)

      if @measurement.save
        flash[:success] = "Measurements recorded"
      else
      	flash[:danger] = "Measurements didn't save!"
      end
    
    else
      flash[:danger] = "You are not authorized to enter measurements!"
		end
    redirect_to measurements_path
	end
	
	def edit
		@measurement = Measurement.find_by(id: params[:id])
	end
	
	def update
	  @measurement = Measurement.find_by(id: params[:id])
		if authorized_to_edit(@measurement.user)
		    
      if @measurement.update_attributes(measurement_params)
        flash[:success] = "Measurements updated"
      else
      	flash[:danger] = "Measurements didn't save!"
      end
    
    else
      flash[:danger] = "You are not authorized to edit these 
      									measurements!"
		end
    redirect_to measurements_path
	end
	
	def destroy
    @measurement = Measurement.find_by(id: params[:id])

		if authorized_to_edit(@measurement.user)
      @measurement.destroy
      flash[:success] = "Measurements deleted"
    else
      flash[:danger] = "You are not authorized to delete these
      									measurements!"
		end
    redirect_to measurements_path
	end
	
	private
	
		def measurement_params
			params.require(:measurement).permit(
				:created_at,
				:weight,
				:body_fat,
	    	:chest,
	    	:waist,
	    	:rt_arm,
	    	:rt_forearm,
	    	:hips,
	    	:rt_thigh,
	    	:rt_calf
			)
		end
		
		def date_check
			master_date_check(measurement_params[:created_at])
		end
		
		def authorized_to_edit(user)
			(current_license != "client" && 
       current_user.clients.include?(user)) ||
       current_license == "owner"
		end
		
		def authorized_to_see(user)
			(current_license != "client" && 
       current_user.clients.include?(user)) ||
       current_license == "owner" ||
       current_user == user
		end
			
end
