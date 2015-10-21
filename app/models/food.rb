class Food < ActiveRecord::Base
  before_save :singularize, :capitalize
  before_create :singularize, :capitalize

	validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :sub_exchange_id }
  validates :carbs_per_serving, presence: true
  validates :protein_per_serving, presence: true
  validates :fat_per_serving, presence: true
  validates :servings_per_exchange, presence: true
  validates :serving_type, presence: true
  validates :sub_exchange_id, presence: true

  belongs_to :user
	belongs_to :sub_exchange
	has_many :food_assignments, dependent: :destroy

  def carbs_per_exchange
    self.carbs_per_serving * self.servings_per_exchange
  end
  
  def protein_per_exchange
    self.protein_per_serving * self.servings_per_exchange
  end
  
  def fat_per_exchange
    self.fat_per_serving * self.servings_per_exchange
  end
  
  def kcals_per_serving
    4 * (carbs_per_serving + protein_per_serving) + 9 * fat_per_serving
  end
  
  def kcals_per_exchange
    self.kcals_per_serving * self.servings_per_exchange
  end
  
  def serving_type_text(exchanges)
    if exchanges * servings_per_exchange == 1
      serving_type
    else
      serving_type.pluralize
    end
  end
  
  def servings_per_exchange_text
    "#{"%g" % ("%.2f" % servings_per_exchange)} #{serving_type_text(1)} per exchange"
  end
  
  def sub_exchange_for_group
    [self.sub_exchange]
  end
  
  def exchange_for_dropdown
    if  self.sub_exchange.exchange.name.include?("Meat") ||
        self.sub_exchange.exchange.name.include?("Milk")
      self.sub_exchange.name
    else
      self.sub_exchange.exchange.name
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
      self.serving_type = self.serving_type.singularize if !self.serving_type.blank?
    end
    
    private
	
		def capitalize
			self.name = self.name.titleize if !self.name.blank?
			self.serving_type = self.serving_type.downcase if !self.serving_type.blank?
		end

end