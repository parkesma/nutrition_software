class User < ActiveRecord::Base
	validates :username,   presence: true,
	                       uniqueness: { case_sensitive: false }
	validates :password,   presence: true
	validates :license,    presence: true
	validates :last_name,  presence: true
	validates :first_name, presence: true,
	                       uniqueness: { case_sensitive: false,
	                                     scope: :last_name }
	has_many :top_down_relationships, class_name: "Relationship",
	                                  foreign_key: "sub_id",
	                                  dependent: :destroy
	has_many :subs, through: :top_down_relationships, source: "sub"
	has_one :bottom_up_relationship, class_name: "Relationship",
	                                 foreign_key: "sup_id",
	                                 dependent: :destroy
  has_one :sup, through: :bottom_up_relationship, source: "sup"
	#has_many :planned_foods, through _
	#has_many :planned_exercises, through _
	#has_many :measurements, through _
	#has_many :bf_measurements, through _
	
	def clients

	  trainer_id = self.id
	  if self.license == "employee"
			trainer_id = self.employer.id
	  end

		all_subs = "SELECT sub_id FROM relationships
		            WHERE sup_id = #{trainer_id}"
		User.where("id IN (#{all_subs})
		            AND license = 'client'")
	end

	def employees
		all_subs = "SELECT sub_id FROM relationships
		            WHERE sup_id = #{self.id}"
		User.where("id IN (#{all_subs})
		            AND license = 'employee'")
	end
	
	def employer
		all_sups = "SELECT sup_id FROM relationships
		            WHERE sub_id = #{self.id}"
		User.where("id IN (#{all_sups})
		            AND license = 'employer'").first
	end

	def trainer
		all_sups = "SELECT sup_id FROM relationships
		            WHERE sub_id = #{self.id}"
		User.where("id IN (#{all_sups})
		            AND license != 'employee'").first
	end

end