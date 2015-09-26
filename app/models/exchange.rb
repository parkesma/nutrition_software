class Exchange < ActiveRecord::Base
	validates :name, presence: true, uniqueness: { case_sensitive: false }
	belongs_to :user
	has_many :sub_exchanges, dependent: :destroy
	
end
