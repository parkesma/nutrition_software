class SupplementAssignment < ActiveRecord::Base
	validates :number_of_servings, presence: true
	belongs_to :meal
	belongs_to :supplement_product
	
	def servings_text
		if self.number_of_servings = 1
			"1 #{self.supplement_product.serving_type} of "
		else
			"#{self.number_of_servings} #{self.supplement_product.serving_type.pluralized} of "
		end
	end
	
	def serving_type_text
		if self.number_of_servings = 1
			"#{self.supplement_product.serving_type} of "
		else
			"#{self.supplement_product.serving_type.pluralized} of "
		end
	end
end
