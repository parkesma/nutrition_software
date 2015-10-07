class SupplementProduct < ActiveRecord::Base
	before_save :singularize, :capitalize
	before_create :singularize, :capitalize

	validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :supplement_brand_id }
	validates :serving_type, presence: true
	validates :servings_per_bottle, presence: true
	validates :retail_package_type, presence: true
	validates :supplement_brand_id, presence: true
	belongs_to :user
	belongs_to :supplement_brand
	has_many :supplement_assignments, dependent: :destroy
	
	def drop_down_text
		"#{self.supplement_brand.name}: #{self.name}"
	end
	
	def package_text(number)
		if number == 1
			self.retail_package_type
		else
			self.retail_package_type.pluralize
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
    def singularize
      self.serving_type = self.serving_type.singularize
      self.retail_package_type = self.retail_package_type.singularize
    end	
    
    def capitalize
    	self.name = self.name.titleize
    	self.serving_type = self.serving_type.downcase
    	self.retail_package_type = self.retail_package_type.downcase
    end
end