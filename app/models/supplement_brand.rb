class SupplementBrand < ActiveRecord::Base
	validates :name, presence: true, uniqueness: { case_sensitive: false }
	belongs_to :user
	has_many :supplement_products, dependent: :destroy
end
