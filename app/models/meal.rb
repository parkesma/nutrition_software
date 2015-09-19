class Meal < ActiveRecord::Base
	belongs_to :user
	has_many :food_assignments, dependent: :destroy

	def carbs
		self.food_assignments.sum(:carbs)
	end
	
	def protein
		self.food_assignments.sum(:protein)
	end
	
	def fat
		self.food_assignments.sum(:fat)
	end
	
	def kcals
		self.food_assignments.sum(:kcals)
	end
	
end
