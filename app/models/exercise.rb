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
	
	private
	
		def capitalize
			self.name = self.name.titleize if !self.name.blank?
		end
end
