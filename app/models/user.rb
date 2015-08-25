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
	  if self.license == "employee" && !self.employer.nil?
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
	
	def name
		"#{first_name} #{last_name}"
	end
	
	def possible_licenses
		if self.license == "owner"
			["owner",
			 "employer",
			 "employee",
			 "trainer",
			 "unlimited student",
			 "student",
			 "client"]

		elsif self.license == "employer"
			["employee",
			 "client"]
		end
	end
	
	def home_city_state_zip
		"#{home_city }#{', ' if !home_city.blank?  && !home_state.blank?}#{
			 home_state}#{' '  if !home_state.blank? && !home_zip.blank?  }#{
			 home_zip.to_s}"
	end
	
	def work_city_state_zip
		"#{work_city }#{', ' if !work_city.blank?  && !work_state.blank?}#{
		   work_state}#{' '  if !work_state.blank? && !work_zip.blank?  }#{
		   work_zip.to_s}"
	end 
	
	def link(website)
		"http://#{website}"
	end
	
end