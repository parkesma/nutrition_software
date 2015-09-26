class SupplementProductsController < ApplicationController
	before_action :set_supplement_product, only: [:update, :destroy]
	
	def create
    if current_license == "client"
      flash[:danger] = "You are not authorized to create supplement products"
      redirect_to root_path
    else
      if current_license == "employee"
        @supplement_product = current_user.employer.supplement_products.new(supplement_product_params)
      else      
        @supplement_product = current_user.supplement_products.new(supplement_product_params)
      end

      if @supplement_product.save
        flash[:success] = 'Supplement product was successfully created.'
        redirect_to exchanges_path
      else
        flash[:danger] = "Supplement product failed to save!"
        redirect_to exchanges_path
      end
    end
	end
	
	def update
		if !authorized_to_change(@supplement_product)
      flash[:danger] = "You are not authorized to edit this supplement product"
      redirect_to root_path
    else
    
      if @supplement_product.update(supplement_product_params)
        flash[:success] = 'Supplement product was successfully updated.'
        redirect_to exchanges_path
      else
        flash[:danger] = "Changes failed to save"
        redirect_to exchanges_path
      end
		end
	end
	
	def destroy
    if !authorized_to_change(@supplement_product) || 
        current_license == "employee"
      flash[:danger] = "You are not authorized to delete this supplement product"
      redirect_to root_path
    elsif @supplement_product.destroy
      flash[:success] = 'Supplement product was deleted.'
      redirect_to exchanges_path
    end
	end
	
	private

		# Use callbacks to share common setup or constraints between actions.
    def set_supplement_product
      @supplement_product = SupplementProduct.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplement_product_params
      params.require(:supplement_product).permit(
        :name, :serving_type, :servings_per_bottle, :supplement_brand_id
      )
    end
    
    def authorized_to_change(supplement_product)
			current_license == "owner" ||
			
			(current_license != "client" && 
       current_user.supplement_products.include?(supplement_product)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.supplement_products.include?(supplement_product)
			)
    end
    
    def authorized_to_see(supplement_product)
			current_license == "owner" ||
			 
			exchange.user.license == "owner" ||
			
			(current_license != "client" && 
       current_user.supplement_products.include?(supplement_product)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.supplement_products.include?(supplement_product)
			)
    end
end