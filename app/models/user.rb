class User < ActiveRecord::Base
	before_save		:capitalize
	before_create :capitalize
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
	has_many :notes
	has_many :measurements
	has_many :fat_measurements
	#has_many :planned_foods, through _
	#has_many :planned_exercises, through _
	
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
			 "CFNS",
			 "unlimited student",
			 "student",
			 "client"]

		elsif self.license == "employer"
			["employee",
			 "client"]
		end
	end
	
	#get for cfns virtual attribute
	def cfns
		trainer
	end
	
	#get for expiration date string virtual attribute
	def expiration_date_string
		expiration_date.to_s
	end
	
	#set for expiration date string virtual attribute
	def expiration_date_string=(expiration_date_str)
		self.expiration_date = Time.parse(expiration_date_str)
	rescue ArgumentError
		@starting_date_invalid = true
	end
		
	#get/set for home_city_state_zip virtual attribute
#		def home_csz_string
#			home_csz_display
#		end
		
#		def home_csz_display
#			"#{home_city }#{', ' if !home_city.blank?  && !home_state.blank?}#{
#			 	home_state}#{' '  if !home_state.blank? && !home_zip.blank?  }#{
#			 	home_zip.to_s}"
#		end
	
#		def home_csz_string=(home_csz_str)
#			if !home_csz_str.blank?
#				split_string = home_csz_str.split(' ')
#				self.home_city = split_string[0].remove(",")
#				self.home_state = split_string[1]
#				self.home_zip = split_string[2]
#			end
#		end

	#get/set for work_city_state_zip virtual attribute
#		def work_csz_string
#			work_csz_display
#		end
		
#		def work_csz_display
#			"#{work_city }#{', ' if !work_city.blank?  && !work_state.blank?}#{
#			 	work_state}#{' '  if !work_state.blank? && !work_zip.blank?  }#{
#			 	work_zip.to_s}"
#		end
	
#		def work_csz_string=(work_csz_str)
#			if !work_csz_str.blank?
#				split_string = work_csz_str.split(' ')
#				self.work_city = split_string[0].remove(",")
#				self.work_state = split_string[1]
#				self.work_zip = split_string[2]
#			end
#		end
	
	def link(website)
		"http://#{website}"
	end

	#get for starting date string virtual attribute
	def starting_date_string
		starting_date.to_s
	end
	
	#set for starting date string virtual attribute
	def starting_date_string=(starting_date_str)
		self.starting_date = Time.parse(starting_date_str)
	rescue ArgumentError
		@starting_date_invalid = true
	end
		
	#get for date of birth string virtual attribute
	def date_of_birth_string
		date_of_birth.to_s
	end
	
	#set for date of birth string virtual attribute
	def date_of_birth_string=(date_of_birth_str)
		self.date_of_birth = Time.parse(date_of_birth_str)
	rescue ArgumentError
		@date_of_birth_invalid = true
	end

	#validate starting and dates string virtual attributes
	def validate
		error.add("That starting date was invalid") if @starting_date_invalid
		error.add("That birthdate was invalid") if @date_of_birth_invalid
		error.add("That expiration date was invalid") if @expiration_date_invalid
	end
	
	def age
		(Date.today - date_of_birth).to_i / 365 if !date_of_birth.blank?
	end
	
	def basic_mr
		if !(present_weight.blank? || height.blank? || age.blank?)
			if gender == "F"
				655 + 9.6 * present_weight / 2.2 + 1.8 * height * 2.54 - 4.7 * age
			else
				66 + 13.7 * present_weight / 2.2 + 5 * height * 2.54 - 6.8 * age
			end
		end
	end

	def bmr_plus_sa
		if !(basic_mr.blank? && measured_metabolic_rate.blank?)
			if activity_index.blank? 
				if measured_metabolic_rate.blank?
					basic_mr
				else
					measured_metabolic_rate
				end
			else
				if measured_metabolic_rate.blank?
					base = basic_mr
				else
					base = measured_metabolic_rate
				end
				base * ( 1.2 + (activity_index - 1) * (0.35 - 0.2) / (10 - 1))
			end
		end
	end

	def sa_needs
		if !bmr_plus_sa.blank?
			if measured_metabolic_rate.blank?
				bmr_plus_sa - basic_mr
			else
				bmr_plus_sa - measured_metabolic_rate
			end
		end
	end

	def exercise_calories
		#if !average_daily_calories_burned
			#average_daily_calories_burned
		#end
		1000 #fix
	end

	def bmr_plus_sa_plus_exercise
		bmr_plus_sa + exercise_calories if 
		!(bmr_plus_sa.blank? || exercise_calories.blank?)
	end

	def tef(body_fat)
		if !present_body_fat.blank?
			if present_body_fat > 30
				4
			elsif gender == "M"					
				if present_body_fat > 15
					10 - 0.4 * (present_body_fat - 15)
				else
					10
				end
			else
				if present_body_fat > 22
					10 - 0.75 * (present_body_fat - 22)
				else
					10
				end
			end
		end
	end

	def tef_factor
		bmr_plus_sa_plus_exercise * tef(present_body_fat) / 100 if
		!(bmr_plus_sa_plus_exercise.blank? || tef(present_body_fat).blank?)
	end

	def present_energy_expenditure
		if !(bmr_plus_sa.blank? || tef_factor.blank?)
			bmr_plus_sa_plus_exercise + tef_factor
		end
	end

	def ibw
		if !height.blank?
			if gender=="F"
				(height - 60) * 5 + 100
			else
				(height - 60) * 6 + 106
			end
		end
	end
	
	def to_kg(lbs)
		sprintf("%0.2f", lbs/2.2) if !lbs.blank?
	end
	
	def daily_caloric_needs
		#if !daily_average_calories.blank?
			#daily_average_calories
		#elsif
		if !present_energy_expenditure.blank?
			present_energy_expenditure * 0.8
		end
			
	end
	
	def daily_deficit
		if !(daily_caloric_needs.blank? || 
				 present_energy_expenditure.blank?)
			daily_caloric_needs - present_energy_expenditure
		end
	end
	
	def fluid_min
		if !present_weight.blank?
			present_weight / 2
		end
	end
	
	def fluid_max
		present_weight
	end
	
	def present_fat_mass
		if !(present_weight.blank? || present_body_fat.blank?)
			present_weight * present_body_fat / 100
		end
	end
	
	def present_lean_mass
		if !(present_weight.blank? || present_body_fat.blank?)
			present_weight - present_fat_mass
		end
	end
	
	def desired_lean_mass
		if !(desired_weight.blank? || desired_body_fat.blank?)
			desired_weight - desired_fat_mass
		end
	end
	
	def desired_fat_mass
		if !(desired_weight.blank? || desired_body_fat.blank?)
			desired_weight * desired_body_fat / 100
		end
	end
	
	def estimated_muscle_changes
		if !(present_lean_mass.blank? || desired_lean_mass.blank?)
			desired_lean_mass - present_lean_mass
		end
	end
	
	def estimated_fat_changes
		if !(present_fat_mass.blank? || desired_fat_mass.blank?)
			desired_fat_mass - present_fat_mass
		end
	end
	
	def estimated_total_changes
		if !(estimated_muscle_changes.blank? || estimated_fat_changes.blank?)
			(estimated_muscle_changes ** 2) ** 0.5 + (estimated_fat_changes ** 2) ** 0.5
		end
	end
	
	def target_heart_rate_min
		if !(resting_heart_rate.blank? || age.blank?)
			0.6 * (220 - age - resting_heart_rate) + resting_heart_rate
		end
	end
	
	def target_heart_rate_max
		if !(resting_heart_rate.blank? || age.blank?)
			0.7 * (220 - age - resting_heart_rate) + resting_heart_rate
		end
	end
	
	def vo2max_endurance_min
		if !(resting_heart_rate.blank? || age.blank?)
			0.7 * (220 - age - resting_heart_rate) + resting_heart_rate
		end
	end
	
	def vo2max_endurance_max
		if !(resting_heart_rate.blank? || age.blank?)
			0.8 * (220 - age - resting_heart_rate) + resting_heart_rate
		end
	end
	
	private
	
		def capitalize
			self.first_name = self.first_name.titleize if !self.first_name.blank?
			self.last_name  = self.last_name.titleize  if !self.last_name.blank?
			self.home_city  = self.home_city.titleize  if !self.home_city.blank?
			self.work_city  = self.work_city.titleize  if !self.work_city.blank?
			self.company    = self.company.titleize    if !self.company.blank?
			return true
		end
end