class FoodAssignmentsController < ApplicationController
	before_action :set_food_assignment, only: [:update, :move_food_up, :move_food_down, :destroy]
	
	def create
		if !authorized_to_create_for(focussed_user)
	  	flash[:danger] = "You are not authorized to enter food assignments for this client"
		else
      meal = Meal.find(food_assignment_params[:meal_id])
      params[:food_assignment][:number_of_exchanges] = 1 if !params[:food_assignment][:number_of_exchanges]

      sub_exchange = SubExchange.find_by(name: params[:category])

      if sub_exchange.nil?
      	supplement_product_id = SupplementProduct.find_by(name: params[:category]).id
      	number_of_servings = params[:food_assignment][:number_of_exchanges]
      	
      	@supplement_assignment = meal.supplement_assignments.build(
      		supplement_product_id: supplement_product_id,
      		number_of_servings: number_of_servings
      	)

      	if !@supplement_assignment.save
	      	flash[:danger] = "Supplement assignment didn't save!"
      	end

      else
      	params[:food_assignment][:food_id] = sub_exchange.first_food_id

	      @food_assignment = meal.food_assignments.build(food_assignment_params)

				if !@food_assignment.save
      		flash[:danger] = "Food assignments didn't save!"
				end
      end
		end
		redirect_to meals_path
	end
	
	def update
		if authorized_to_edit_for(@food_assignment.meal.user)
		  
		  if food_assignment_params[:position] != @food_assignment.position
		    above = @food_assignment.meal.food_assignments.where(
			          "position = ?", @food_assignment.position - 1)
		    above.update_all(position: @food_assignment.position) if above.size > 0
		  end

		  if params[:sub_exchange] && params[:sub_exchange].to_i != @food_assignment.food.sub_exchange.id
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
		if authorized_to_delete_for(@food_assignment.meal.user)
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
    
    def authorized_to_create_for(user)
			current_license == "owner" ||
			
			(current_license != "client" && 
       current_user.clients.include?(user)
      )
    end
    
    def authorized_to_edit_for(user)
    	authorized_to_create_for(user) || 
    	current_user == user
    end
    
    def authorized_to_delete_for(user)
    	authorized_to_create_for(user) &&
    	current_license != "employee"
    end
end