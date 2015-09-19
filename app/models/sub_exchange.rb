class SubExchange < ActiveRecord::Base
	validates :name,   presence: true
	belongs_to :user
	belongs_to :exchange
	has_many :foods, dependent: :destroy
	
end
