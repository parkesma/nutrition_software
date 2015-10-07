class Exercise < ActiveRecord::Base
	before_save :capitalize
	before_create :capitalize

	validates :category,   					presence: true
	validates :name,   							presence: true, uniqueness: { case_sensitive: false }
	validates :Kcal_per_kg_per_hr,	presence: true
	
	belongs_to :user
	has_many :exercise_assignments, dependent: :destroy
	
	def name_description
		if description
			name + ": " + description
		else
			name
		end
	end
	
	def self.import(file)
		csv = CSV.parse(file, headers: true)
		csv.each do |row|
			new_hash = row.to_hash
			new_exercise = Exercise.new
			new_exercise.attributes.each do |attribute|
				new_exercise[attribute[0]] = new_hash[attribute[0]]
			end
			new_exercise.save!
		end
	end
	
	private
	
		def capitalize
			self.name = self.name.titleize if !self.name.blank?
		end
end
