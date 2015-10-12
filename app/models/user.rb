class User < ActiveRecord::Base
	before_save		:capitalize
	before_create :capitalize
	validates :username,   presence: true, uniqueness: { case_sensitive: false }
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
  has_one :sup, through: :bottom_up_relationship, source: "sup", 
  							dependent: :destroy
	has_many :notes, dependent: :destroy
	has_many :measurements, dependent: :destroy
	has_many :fat_measurements, dependent: :destroy
	has_many :exercises, dependent: :destroy
	has_many :exercise_assignments, dependent: :destroy
	has_many :exchanges, dependent: :destroy
	has_many :sub_exchanges, dependent: :destroy
	has_many :foods, dependent: :destroy
	has_many :meals, dependent: :destroy
	has_many :supplement_brands, dependent: :destroy
	has_many :supplement_products, dependent: :destroy
	has_many :supplement_assignments, dependent: :destroy
	
	def clients

	  if self.license == "employee" && !self.employer.nil?
			trainer_id = self.employer.id
		else
			trainer_id = self.id
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
		if self.license == "client"
			all_sups = "SELECT sup_id FROM relationships
		            	WHERE sub_id = #{self.id}"
			User.where("id IN (#{all_sups})
		            	AND license != 'employee'").first
		end
	end
	
	def trainer_id
		if self.trainer
			self.trainer.id
		else
			0
		end
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
#	def expiration_date_string
#		expiration_date.to_s
#	end
	
	#set for expiration date string virtual attribute
#	def expiration_date_string=(expiration_date_str)
#		self.expiration_date = Time.parse(expiration_date_str)
#	rescue ArgumentError
#		@starting_date_invalid = true
#	end
		
	def link(website)
		"http://#{website}"
	end

	#get for starting date string virtual attribute
#	def starting_date_string
#		starting_date.to_s
#	end
	
	#set for starting date string virtual attribute
#	def starting_date_string=(starting_date_str)
#		self.starting_date = Time.parse(starting_date_str)
#	rescue ArgumentError
#		@starting_date_invalid = true
#	end
		
	#get for date of birth string virtual attribute
#	def date_of_birth_string
#		date_of_birth.to_s
#	end
	
	#set for date of birth string virtual attribute
#	def date_of_birth_string=(date_of_birth_str)
#		self.date_of_birth = Time.parse(date_of_birth_str)
#	rescue ArgumentError
#		@date_of_birth_invalid = true
#	end

	#validate starting and dates string virtual attributes
#	def validate
#		error.add("That starting date was invalid") if @starting_date_invalid
#		error.add("That birthdate was invalid") if @date_of_birth_invalid
#		error.add("That expiration date was invalid") if @expiration_date_invalid
#	end
	
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
		total = 0
		self.exercise_assignments.each do |a|
			total += a.daily_kcal if a.daily_kcal
		end
		total
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
		if !daily_kcals.blank?
			daily_kcals
		end
	end
	
	def daily_deficit
		if !(daily_caloric_needs.blank? || present_energy_expenditure.blank?)
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
	
	def supplements_summary
		supplements_per_day = {}

		self.supplement_assignments.each do |sa|
			supplement_name = sa.supplement_product.drop_down_text
			if supplements_per_day[supplement_name].nil?
				supplements_per_day[supplement_name] = 
					[sa.supplement_product.servings_per_bottle, sa.number_of_servings, sa.supplement_product]
			else
				supplements_per_day[supplement_name][1] += sa.number_of_servings
			end
		end
		
		supplements_summary = []
		supplements_per_day.each do |sa, array| 
			number_per_week = (array[1] * 7 / array[0]).round(2)
			number_per_month = (array[1] * 365 / 12.00 / array[0]).round(2)
			weekly_packages = array[2].package_text(number_per_week)
			monthly_packages = array[2].package_text(number_per_month)
			hash = {}
			hash[:name] = sa
			hash[:per_week] = "#{number_per_week} #{weekly_packages}"
			hash[:per_month] = "#{number_per_month} #{monthly_packages}"
			supplements_summary.push(hash)
		end
		
		supplements_summary
	end
	
	def daily_carbs
		total = 0
		self.meals.each do |meal|
			total += meal.carbs
		end
		total
	end
	
	def daily_protein
		total = 0
		self.meals.each do |meal|
			total += meal.protein
		end
		total
	end
	
	def daily_fat
		total = 0
		self.meals.each do |meal|
			total += meal.fat
		end
		total
	end
	
	def daily_kcals
		total = 0
		self.meals.each do |meal|
			total += meal.kcals
		end
		total
	end
	
	def self.import(file)
		csv = CSV.parse(file, headers: true)
		csv.each do |row|
			new_hash = row.to_hash
			new_instance = self.find_by(name: new_hash["name"].titleize) || self.new
			new_instance.attributes.each do |attribute|
				new_instance[attribute[0]] = new_hash[attribute[0]] if new_hash[attribute[0]]
			end
			new_instance.save!
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