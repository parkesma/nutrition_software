class FoodAssignmentsController < ApplicationController
	before_action :set_food_assignment, only: [:update, :destroy]
	
	def create
		if authorized_to_edit(focussed_user)
      
      meal = Meal.find(food_assignment_params[:meal_id])
      @food_assignment = meal.food_assignments.build(food_assignment_params)

      if !@food_assignment.save
      	flash[:danger] = "Food assignments didn't save!"
      end
    
    else
      flash[:danger] = "You are not authorized to enter food assignments for this 
      client"
		end
    redirect_to meals_path
	end
	
	def update
		if authorized_to_edit(@food_assignment.meal.user)
		  
      if @food_assignment.update_attributes(food_assignment_params)
        flash[:success] = "Food assignment updated"
      else
      	flash[:danger] = "Food assignment didn't save!"
      end
    
    else
      flash[:danger] = "You are not authorized to edit this food assignment!"
		end
    redirect_to meals_path
	end
	
	def destroy
		if authorized_to_edit(@food_assignment.meal.user)
      @food_assignment.destroy
      flash[:success] = "Food assignment deleted"
    else
      flash[:danger] = "You are not authorized to delete this
      									food assignment!"
		end
    redirect_to meals_path
	end
	
	private

		# Use callbacks to share common setup or constraints between actions.
    def set_food_assignment
      @food_assignment = FoodAssignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def food_assignment_params
      params.require(:food_assignment).permit(
				:meal_id, :food_id, :number_of_exchanges
      )
    end
    
    def authorized_to_edit(user)
			current_license == "owner" ||
			
			(current_license != "client" && 
       current_user.clients.include?(user)
      )
    end
    
    def authorized_to_see(food_assignment)
			current_license == "owner" ||
			 
			current_user == food_assignment.meal.user ||
			
			(current_license != "client" && 
       current_user.clients.include?(food_assignment.meal.user)
      )
    end
	
end