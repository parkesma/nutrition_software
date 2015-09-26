class SupplementAssignmentsController < ApplicationController
	before_action :set_supplement_assignment, only: [:update, :destroy]
	
#	def create
#		if authorized_to_edit(focussed_user)
#      
#      meal = Meal.find(supplement_assignment_params[:meal_id])
#      params[:supplement_assignment][:number_of_servings] = 1 if 
#      	!params[:supplement_assignment][:number_of_servings]
#      @supplement_assignment = meal.supplement_assignments.build(supplement_assignment_params)
#
#      if !@supplement_assignment.save
#      	flash[:danger] = "Supplement assignment didn't save!"
#      end
#    
#    else
#      flash[:danger] = "You are not authorized to enter supplement assignments for this client"
#		end
#    redirect_to meals_path
#	end
	
	def update
		if authorized_to_edit(@supplement_assignment.meal.user)
		  	  
		  respond_to do |format|
        if @supplement_assignment.update_attributes(supplement_assignment_params)
          format.html { redirect_to meals_path }
          format.js
          format.json { render :show, status: :ok, location: @supplement_assignment }
        else
          flash[:danger] = "Supplement assignment didn't save!"
          format.html { redirect_to meals_path }
        end
      end
 
    else
      flash[:danger] = "You are not authorized to edit this supplement assignment!"
      redirect_to meals_path
		end
	end
	
	def destroy
		if authorized_to_edit(@supplement_assignment.meal.user)
      @supplement_assignment.destroy
      flash[:success] = "Supplement assignment deleted"
    else
      flash[:danger] = "You are not authorized to delete this Supplement assignment!"
		end
    redirect_to meals_path
	end
	
	private

		# Use callbacks to share common setup or constraints between actions.
    def set_supplement_assignment
      @supplement_assignment = SupplementAssignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplement_assignment_params
      params.require(:supplement_assignment).permit(
				:meal_id, :supplement_product_id, :number_of_servings
      )
    end
    
    def authorized_to_edit(user)
			current_license == "owner" ||
			
			(current_license != "client" && 
       current_user.clients.include?(user)
      )
    end
    
    def authorized_to_see(supplement_assignment)
			current_license == "owner" ||
			 
			current_user == supplement_assignment.meal.user ||
			
			(current_license != "client" && 
       current_user.clients.include?(supplement_assignment.meal.user)
      )
    end
	
end
