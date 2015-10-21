class FoodAssignment < ActiveRecord::Base
	validates :number_of_exchanges, presence: true
	belongs_to :meal
	belongs_to :food
	
	def servings
		self.food.servings_per_exchange * self.number_of_exchanges
	end
	
	def servings_text
		if servings == 1
			"1 #{self.food.serving_type} of"
		else
			"#{'%g' % ('%.2f' % (self.servings))} #{self.food.serving_type.pluralize} of"
		end
	end
	
	def grouped_available_foods
		sups_foods = Food.joins(:user).where("users.license = ? OR users.id = ?", 
												 								 "owner", 					 self.meal.user.trainer_id)
		if 	self.food.sub_exchange.exchange.name.include?("Meat") ||
				self.food.sub_exchange.exchange.name.include?("Milk")
			same_exchange_foods = self.food.sub_exchange.foods
		else
			same_exchange_sub_exchanges = self.food.sub_exchange.exchange.sub_exchanges.pluck(:id)
			same_exchange_foods = Food.where("sub_exchange_id IN (?)", same_exchange_sub_exchanges)
		end
		available_foods = same_exchange_foods.merge(sups_foods)
		available_sub_exchanges = []
		available_foods.each do |food|
			available_sub_exchanges.push(food.sub_exchange)
		end
		grouped_available_foods = {}
		available_sub_exchanges.uniq.each do |sub_exchange|
			
			grouped_available_foods[sub_exchange.name] = available_foods.select{ |food|
				food.sub_exchange == sub_exchange
			}.map { |food| 
					[food.name, food.id]
			}
		end
		return grouped_available_foods
	end

end