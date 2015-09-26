class FoodAssignment < ActiveRecord::Base
	validate :number_of_exchanges
	belongs_to :meal
	belongs_to :food
	
	def servings
		self.food.servings_per_exchange * self.number_of_exchanges
	end
	
	def servings_text
		if servings == 1
			"#{self.servings} #{self.food.serving_type} of"
		else
			"#{self.servings} #{self.food.serving_type.pluralize} of"
		end
	end
	
	def available_foods
		sups_foods = Food.joins(:user).where("users.license = ? OR users.id = ?", 
			"owner", self.meal.user.trainer_id )
		same_category_foods = self.food.sub_exchange.foods
		same_category_foods.merge(sups_foods)
	end

end
