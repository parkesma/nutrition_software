class SupplementAssignment < ActiveRecord::Base
	validates :number_of_servings, presence: true
	validates :user_id, presence: true
	validates :supplement_product_id, presence: true
	belongs_to :user
	belongs_to :supplement_product
	
	def servings_text
		if self.number_of_servings == 1
			"1 #{self.supplement_product.serving_type} of "
		else
			"#{"%g" % ("%.2f" % self.number_of_servings)} #{self.supplement_product.serving_type.pluralize} of "
		end
	end
	
	def serving_type_text
		if self.number_of_servings == 1
			"#{self.supplement_product.serving_type} of "
		else
			"#{self.supplement_product.serving_type.pluralize} of "
		end
	end
	
	def time_options
		[
			["Upon Waking, First Thing"],
			["Before Breakfast"],
			["Meal #1 (Breakfast)"],
			["Meal #2 (AM Snack)"],
			["Before Lunch"],
			["Meal #3 (Lunch)"],
			["Meal #4 (PM Snack)"],
			["Before Dinner"],
			["Meal #5 (Dinner)"],
			["Meal #6 (HS Snack if prescribed)"],
			["Before Workout"],
			["After Workout (15min After)"],
			["Bedtime"]
		]
	end
end
