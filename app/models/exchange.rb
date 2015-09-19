class Exchange < ActiveRecord::Base
	validates :name,   presence: true
	belongs_to :user
	has_many :sub_exchanges, dependent: :destroy
	
end
