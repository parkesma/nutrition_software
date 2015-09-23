class FoodAssignment < ActiveRecord::Base
	validate :number_of_exchanges
	belongs_to :meal
	belongs_to :food
	
	def servings
		self.food.servings_per_exchange * self.number_of_exchanges
	end
	
	def servings_text
		"#{self.servings} #{self.food.serving_type.pluralize} of"
	end

end
