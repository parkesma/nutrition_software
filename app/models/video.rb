class Video < ActiveRecord::Base
	before_save :capitalize
	before_create :capitalize
	validates :title, presence: true
	validates :url, presence: true

	private
	
		def capitalize
			self.title = self.title.titleize if !self.title.blank?
		end
	
end
