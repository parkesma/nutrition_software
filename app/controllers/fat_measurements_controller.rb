class FatMeasurementsController < ApplicationController
	
	def index
		@fat_measurement = focussed_user.fat_measurements.build()
		@fat_measurement.bf_method = session[:bf_method] ||
			@fat_measurement.bf_options[0]
		session[:bf_method] = nil
		@fat_measurements = focussed_user.fat_measurements.order(
			"created_at DESC")

		@bf_chart_hash = {}
		@lean_chart_hash = {}
		@fat_chart_hash = {}
		@weight_chart_hash = {}
		follow_up = 1
		
		@fat_measurements.reverse.each do |m|
			@bf_chart_hash[follow_up] = m.calculated_bf.round(2) if
				m.calculated_bf
			@weight_chart_hash[follow_up] = m.weight.round(2) if 
				m.weight
			@lean_chart_hash[follow_up] =m.lean_mass.round(2) if 
				m.lean_mass
			@fat_chart_hash[follow_up] = m.fat_mass.round(2) if 
				m.fat_mass
			follow_up += 1
		end
			
	end
	
	def create
		if (current_license != "client" && 
        current_user.clients.include?(focussed_user)) ||
        current_license == "owner"
      
      @fat_measurement = focussed_user.fat_measurements.build(
      								fat_measurement_params)

      if @fat_measurement.save
        flash[:success] = "Measurements recorded"
      else
      	flash[:danger] = "Measurements didn't save!"
      end
    
    else
      flash[:danger] = "You are not authorized to enter measurements!"
		end
    redirect_to fat_measurements_path
	end

	def edit
		@fat_measurement = FatMeasurement.find_by(id: params[:id])
	end
	
	def update
	  @fat_measurement = FatMeasurement.find_by(id: params[:id])
		if authorized_to_edit(focussed_user)
		    
      if @fat_measurement.update_attributes(fat_measurement_params)
        flash[:success] = "Measurements updated"
      else
      	flash[:danger] = "Measurements didn't save!"
      end
    
    else
      flash[:danger] = "You are not authorized to edit these 
      									measurements!"
		end
    redirect_to fat_measurements_path
	end
	
	def destroy
    @fat_measurement = FatMeasurement.find_by(id: params[:id])

		if authorized_to_edit(@fat_measurement.user)
      @fat_measurement.destroy
      flash[:success] = "Measurements deleted"
    else
      flash[:danger] = "You are not authorized to delete these
      									measurements!"
		end
    redirect_to fat_measurements_path
	end
	
	def change_method
		
		if params[:view] == "index"
			session[:bf_method] = params[:bf_method]
			redirect_to fat_measurements_path
		
		elsif params[:view] == "edit"
			@fat_measurement = FatMeasurement.find_by(id: params[:id])
			@fat_measurement.update_attribute(:bf_method, params[:bf_method])
			redirect_to edit_fat_measurement_path(@fat_measurement)
		
		end
		
	end
	
	private
	
		def fat_measurement_params
			params.require(:fat_measurement).permit(
				:created_at, :weight, :chest, :abdomen, :thigh, :tricep,
    		:subscapular, :iliac_crest, :calf, :bicep, :lower_back, :neck, :hip,
    		:midaxillary, :measured_bf, :bf_method
			)
		end

		def authorized_to_edit(user)
			(current_license != "client" && 
       current_user.clients.include?(user)) ||
       current_license == "owner"
		end		
	
end