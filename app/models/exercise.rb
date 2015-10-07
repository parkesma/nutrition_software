class Exercise < ActiveRecord::Base
	before_save :capitalize
	before_create :capitalize

	validates :category,   					presence: true
	validates :name,   							presence: true, uniqueness: { case_sensitive: false }
#	validates :Kcal_per_kg_per_hr,  presence: true, unless: ->(exercise){exercise.kcal_per_hr.present?}
#	validates :kcal_per_hr, presence: true, unless: ->(exercise){exercise.Kcal_per_kg_per_hr.present?}
	
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
			new_instance = self.find_by(name: new_hash["name"].titleize) || self.new
			new_instance.attributes.each do |attribute|
				new_instance[attribute[0]] = new_hash[attribute[0]] if new_hash[attribute[0]]
			end
			new_instance.save!
		end
	end
	
	private
	
		def capitalize
			self.name = self.name.titleize if !self.name.blank?
		end
end
