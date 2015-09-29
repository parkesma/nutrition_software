class Exchange < ActiveRecord::Base
	before_save		:capitalize
	before_create :capitalize

	validates :name, presence: true, uniqueness: { case_sensitive: false }
	belongs_to :user
	has_many :sub_exchanges, dependent: :destroy

	private
	
		def capitalize
			self.name = self.name.titleize if !self.name.blank?
		end
	
end
