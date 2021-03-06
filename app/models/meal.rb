class Meal < ActiveRecord::Base
	before_save :capitalize
	before_create :capitalize
	
	belongs_to :user
	has_many :food_assignments, dependent: :destroy
	validates :name, presence: true
	validates :time, presence: true

	def carbs
		total = 0
		self.food_assignments.each do |fa|
			total += fa.food.carbs_per_exchange * fa.number_of_exchanges
		end
		total
	end
	
	def protein
		total = 0
		self.food_assignments.each do |fa|
			total += fa.food.protein_per_exchange * fa.number_of_exchanges
		end
		total
	end
	
	def fat
		total = 0
		self.food_assignments.each do |fa|
			total += fa.food.fat_per_exchange * fa.number_of_exchanges
		end
		total
	end
	
	def kcals
		total = 0
		self.food_assignments.each do |fa|
			total += fa.food.kcals_per_exchange * fa.number_of_exchanges
		end
		total
	end
	
	private
	
		def capitalize
			self.name = self.name.titleize if !self.name.blank?
		end
end