class SubExchange < ActiveRecord::Base
	before_save		:capitalize
	before_create :capitalize
	
	validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :exchange_id }
	belongs_to :user
	belongs_to :exchange
	has_many :foods, dependent: :destroy
	
	def drop_down_text
		"#{self.exchange.name}: #{self.name}"
	end
	
	def first_food_id
		if self.foods.size > 0
			self.foods.first.id
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
