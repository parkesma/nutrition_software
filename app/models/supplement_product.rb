class SupplementProduct < ActiveRecord::Base
	validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :supplement_brand_id }
	validates :serving_type, presence: true
	validates :servings_per_bottle, presence: true
	validates :supplement_brand_id, presence: true
	belongs_to :user
	belongs_to :supplement_brand
	has_many :supplement_assignments, dependent: :destroy
	
	def drop_down_text
		"#{self.supplement_brand.name}: #{self.name}"
	end
	
	def package_text(number)
		if number == 1
			self.retail_package_type
		else
			self.retail_package_type.pluralize
		end
	end
		
end