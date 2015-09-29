class SubExchange < ActiveRecord::Base
	before_save		:capitalize
	before_create :capitalize
	
	validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :exchange_id }
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
	
	private
	
		def capitalize
			self.name = self.name.titleize if !self.name.blank?
		end
		
end
