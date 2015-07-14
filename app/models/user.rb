class User < ActiveRecord::Base
	validates :username, presence: true,
	                     uniqueness: { case_sensitive: false }
	validates :password, presence: true
	#has_many :clients, through _
	#has_many :employees, through _
	#belongs_to :trainer, through :trainer_id
	#belongs_to :employer, through :trainer_id
	#has_many :planned_foods, through _
	#has_many :planned_exercises, through _
	#has_many :measurements, through _
	#has_many :bf_measurements, through _
end
