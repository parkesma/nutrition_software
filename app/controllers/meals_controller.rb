class MealsController < ApplicationController
	before_action :set_meal, only: [:update, :destroy]
	
	def index
		if authorized_to_see(focussed_user)
			@meals = focussed_user.meals.order("time ASC")
		else
			flash[:danger] = "You are not authorized to view meals for this client"
			redirect_to root_path
		end
	end
	
	def create
		if authorized_to_edit(focussed_user)
      
      @meal = focussed_user.meals.build(meal_params)

      if !@meal.save
      	flash[:danger] = "meals didn't save!"
      end
    
    else
      flash[:danger] = "You are not authorized to enter meals for this client"
		end
    redirect_to meals_path
	end
	
	def update
		if authorized_to_edit(@meal.user)
		  
      if @meal.update_attributes(meal_params)
        flash[:success] = "Meal updated"
      else
      	flash[:danger] = "Meal didn't save!"
      end
    
    else
      flash[:danger] = "You are not authorized to edit this meal!"
		end
    redirect_to meals_path
	end
	
	def destroy
		if authorized_to_edit(@meal.user)
      @meal.destroy
      flash[:success] = "meals deleted"
    else
      flash[:danger] = "You are not authorized to delete these
      									meals!"
		end
    redirect_to meals_path
	end
	
	private

		# Use callbacks to share common setup or constraints between actions.
    def set_meal
      @meal = Meal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def meal_params
      params.require(:meal).permit(
        :name, :time, :notes
      )
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