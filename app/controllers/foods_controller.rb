class FoodsController < ApplicationController
	before_action :set_food, only: [:edit, :update, :destroy]
	
	def new
	  @food = Food.new
	  @sub_exchange = SubExchange.find_by(id: params[:sub_exchange])
	  @exchange = @sub_exchange.exchange
	end
	
	def create
    if current_license == "client"
      flash[:danger] = "You are not authorized to create foods"
      redirect_to root_path
    else
      if current_license == "employee"
        @food = current_user.employer.foods.new(food_params)
      else      
        @food = current_user.foods.new(food_params)
      end

      if @food.save
        flash[:success] = 'Food was successfully created.'
        redirect_to exchanges_path
      else
        flash.now[:danger] = "Food failed to save!"
        render new_food_path
      end
    end
	end
	
	def edit
	end
	
	def update
		if !authorized_to_change(@food)
      flash[:danger] = "You are not authorized to edit this food"
      redirect_to root_path
    else
    
      if @food.update(food_params)
        flash[:success] = 'Food was successfully updated.'
        redirect_to exchanges_path
      else
        flash.now[:danger] = "Changes failed to save"
        render :edit
      end
		end
	end
	
	def destroy
    if !authorized_to_change(@food) || 
        current_license == "employee"
      flash[:danger] = "You are not authorized to delete this food"
      redirect_to root_path
    elsif @food.destroy
      flash[:success] = 'Food was deleted.'
      redirect_to exchanges_path
    end
	end
	
	private

		# Use callbacks to share common setup or constraints between actions.
    def set_food
      @food = Food.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def food_params
      params.require(:food).permit(
				:sub_exchange_id, :name, :carbs_per_serving, :protein_per_serving, 
				:fat_per_serving, :kcals_per_serving, :servings_per_exchange, 
				:supplement_servings_per_bottle, :serving_type
      )
    end
    
    def authorized_to_change(food)
			current_license == "owner" ||
			
			(current_license != "client" && 
       current_user.foods.include?(food)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.foods.include?(food)
			)
    end
    
    def authorized_to_see(food)
			current_license == "owner" ||
			 
			food.user.license == "owner" ||
			
			(current_license != "client" && 
       current_user.foods.include?(food)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.foods.include?(food)
			)
    end
	
end