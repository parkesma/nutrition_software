class MealsController < ApplicationController
	before_action :set_meal, only: [:update, :destroy]
	
	def index
		@new_meal = focussed_user.meals.build(time: "7:00 AM")
		if authorized_to_see(focussed_user)
			@meals = focussed_user.meals.order("time ASC")
			
      if @meals
			  @meals.each do |m|
			    i = 0
			    m.food_assignments.each do |fa|
			      fa.position = i if fa.position.nil?
			      fa.save
			      i += 1
          end
        end
      end
      
      my_exchanges = Exchange.joins(:user).where("users.license = ? OR users.id = ?", 
		    "owner", @new_meal.user.trainer_id )
		  my_sub_exchanges = SubExchange.joins(:user).where("users.license = ? OR users.id = ?", 
		    "owner", @new_meal.user.trainer_id ).distinct
		  exchanges_no_milk_or_meat = my_exchanges.select{|exchange| !exchange.name.include?("Meat") && 
		    !exchange.name.include?("Milk")
		  }
		  milk_and_meat_sub_exchanges = my_sub_exchanges.select{|sub_exchange| 
		    sub_exchange.exchange.name.include?("Meat") ||
		    sub_exchange.exchange.name.include?("Milk")
		  }
		  @my_exchanges = exchanges_no_milk_or_meat + milk_and_meat_sub_exchanges
		else
			flash[:danger] = "You are not authorized to view meals for this client"
			redirect_to root_path
		end
	end
	
	def create
		if authorized_to_create_for(focussed_user)
      
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
		if authorized_to_edit_for(@meal.user)
		  
      respond_to do |format|
        if @meal.update_attributes(meal_params)
          format.html { redirect_to meals_path }
          format.js
          format.json { render :show, status: :ok, location: @food_assignment }
        else
          flash[:danger] = "Changes didn't save!"
          format.html { redirect_to meals_path }
        end
      end
    
    else
      flash[:danger] = "You are not authorized to edit this meal!"
      redirect_to meals_path
		end
	end
	
	def destroy
		if authorized_to_delete_for(@meal.user)
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
    
    def authorized_to_create_for(user)
      (current_license != "client" && 
       current_user.clients.include?(user)) ||
       current_license == "owner"
    end
	
		def authorized_to_edit_for(user)
			authorized_to_create_for(user)
		end
		
		def authorized_to_delete_for(user)
		  authorized_to_create_for(user) &&
		  current_license != "employee"
		end
    
    def authorized_to_see(user)
			authorized_to_create_for(user) ||
      current_user == user
    end

end