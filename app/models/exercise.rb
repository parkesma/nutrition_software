class Exercise < ActiveRecord::Base
	validates :category,   					presence: true
	validates :name,   							presence: true
	validates :Kcal_per_kg_per_hr,	presence: true
	
	belongs_to :user
	
end
