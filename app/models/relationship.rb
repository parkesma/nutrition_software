class Relationship < ActiveRecord::Base
	validates :sup_id, presence: true
	validates :sub_id, presence: true
	
	belongs_to :sup, class_name: "User"
	belongs_to :sub, class_name: "User"
	
end
