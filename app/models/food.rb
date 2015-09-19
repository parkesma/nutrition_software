class Food < ActiveRecord::Base
	validates :name, presence: true
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
    :carbs_per_serving / :servings_per_exchange
  end
  
  def protein_per_exchange
    :protein_per_serving / :servings_per_exchange
  end
  
  def fat_per_exchange
    :fat_per_serving / :servings_per_exchange
  end
  
  def kcals_per_exchange
    :kcals_per_serving / :servings_per_exchange
  end

end
