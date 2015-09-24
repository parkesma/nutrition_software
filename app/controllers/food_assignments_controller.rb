class FoodAssignmentsController < ApplicationController
	before_action :set_food_assignment, only: [:update, :move_food_up, :move_food_down, :destroy]
	
	def create
		if authorized_to_edit(focussed_user)
      
      meal = Meal.find(food_assignment_params[:meal_id])
      params[:food_assignment][:number_of_exchanges] = 1 if !params[:food_assignment][:number_of_exchanges]
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
		  
		  if food_assignment_params[:position]
		    above = @food_assignment.meal.food_assignments.where(
			          "position = ?", @food_assignment.position - 1)
		    above.update_all(position: @food_assignment.position) if above.size > 0
		  end
		  
		  if params[:sub_exchange] && params[:sub_exchange] != @food_assignment.food.sub_exchange.id
		  		new_sub_exchange = SubExchange.find_by(id: params[:sub_exchange])
		  		params[:food_assignment][:food_id] = new_sub_exchange.first_food_id
		  end
		  
		  respond_to do |format|
        if @food_assignment.update_attributes(food_assignment_params)
          format.html { redirect_to meals_path }
          format.js
          format.json { render :show, status: :ok, location: @food_assignment }
        else
          flash[:danger] = "Food assignment didn't save!"
          format.html { redirect_to meals_path }
        end
      end
 
    else
      flash[:danger] = "You are not authorized to edit this food assignment!"
      redirect_to meals_path
		end
	end
	
	def move_food_up
		above = @food_assignment.meal.food_assignments.where(
			"position = ?", @food_assignment.position - 1)
		above.update_all(position: @food_assignment.position) if above.size > 0
		@food_assignment.update(position: @food_assignment.position - 1)
		respond_to do |format|
		  format.html {redirect_to meals_path}
		  format.js
		end
	end
	
  def move_food_down
		below = @food_assignment.meal.food_assignments.where(
			"position = ?", @food_assignment.position + 1)
		below.update_all(position: @food_assignment.position) if below.size > 0
		@food_assignment.update(position: @food_assignment.position + 1)
		respond_to do |format|
		  format.html {redirect_to meals_path}
		  format.js
		end
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
				:meal_id, :food_id, :number_of_exchanges, :position
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