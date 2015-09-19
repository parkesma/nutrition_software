class FoodAssignment < ActiveRecord::Base
	validate :number_of_exchanges
	belongs_to :meal
	belongs_to :food
	
	def carbs
		self.food.carbs_per_exchange * self.number_of_exchanges
	end
	
	def protein
		self.food.protein_per_exchange * self.number_of_exchanges
	end
	
	def fat
		self.food.fat_per_exchange * self.number_of_exchanges
	end
	
	def kcals
		self.food.kcals_per_exchange * self.number_of_exchanges
	end
	
	def servings
		"#{self.food.servings_per_exchange * self.number_of_exchanges} 
		 #{self.food.serving_type.pluralize}"
	end

end
