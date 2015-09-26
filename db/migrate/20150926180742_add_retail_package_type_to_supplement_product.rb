class AddRetailPackageTypeToSupplementProduct < ActiveRecord::Migration
  def change
    add_column :supplement_products, :retail_package_type, :string
  end
end
