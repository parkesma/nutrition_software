class MeasurementsController < ApplicationController

	def index
		@measurements = focussed_user.measurements.order(
			"created_at DESC")
	end
	
	def create
		if (current_license != "client" && 
        current_user.clients.include?(focussed_user)) ||
        current_license == "owner"
      
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
		if (current_license != "client" && 
        current_user.clients.include?(@measurement.user)) ||
        current_license == "owner"
        
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

		if (current_license != "client" && 
        current_user.clients.include?(@measurement.user)) ||
        current_license == "owner"

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
end
