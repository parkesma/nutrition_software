class SupplementBrand < ActiveRecord::Base
	before_save :capitalize
	before_create :capitalize
	validates :name, presence: true, uniqueness: { case_sensitive: false }
	belongs_to :user
	has_many :supplement_products, dependent: :destroy

	def self.import(file)
		csv = CSV.parse(file, headers: true)
		csv.each do |row|
			new_hash = row.to_hash
			new_instance = self.new
			new_instance.attributes.each do |attribute|
				new_instance[attribute[0]] = new_hash[attribute[0]]
			end
			new_instance.save!
		end
	end

	private
	
		def capitalize
			self.name = self.name.titleize if !self.name.blank?
		end
end