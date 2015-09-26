class Food < ActiveRecord::Base
	validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :sub_exchange_id }
  validates :carbs_per_serving, presence: true
  validates :protein_per_serving, presence: true
  validates :fat_per_serving, presence: true
  validates :kcals_per_serving, presence: true
  validates :servings_per_exchange, presence: true
  validates :serving_type, presence: true

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
    "#{servings_per_exchange} #{serving_type_text(1)} per exchange"
  end

end