class SubExchange < ActiveRecord::Base
	validates :name,   presence: true
	belongs_to :user
	belongs_to :exchange
	has_many :foods, dependent: :destroy
	
	def drop_down_text
		"#{self.exchange.name}: #{self.name}"
	end
	
	def first_food_id
		if self.foods.size > 0
			self.foods.first.id
		end
	end
	
end
