class SupplementBrandsController < ApplicationController
	before_action :set_supplement_brand, only: [:update, :destroy]
	
	def create
    if current_license == "client"
      flash[:danger] = "You are not authorized to create supplement brands"
      redirect_to root_path
    else
      if current_license == "employee"
        @supplement_brand = current_user.employer.supplement_brands.new(supplement_brand_params)
      else      
        @supplement_brand = current_user.supplement_brands.new(supplement_brand_params)
      end

      if @supplement_brand.save
        flash[:success] = 'Supplement brand was successfully created.'
        redirect_to exchanges_path
      else
        flash[:danger] = "Supplement brand failed to save!"
        redirect_to exchanges_path
      end
    end
	end
	
	def update
		if !authorized_to_change(@supplement_brand)
      flash[:danger] = "You are not authorized to edit this supplement brand"
      redirect_to root_path
    else
    
      if @supplement_brand.update(supplement_brand_params)
        flash[:success] = 'Supplement brand was successfully updated.'
        redirect_to exchanges_path
      else
        flash[:danger] = "Changes failed to save"
        redirect_to exchanges_path
      end
		end
	end
	
	def destroy
    if !authorized_to_change(@supplement_brand) || 
        current_license == "employee"
      flash[:danger] = "You are not authorized to delete this supplement brand"
      redirect_to root_path
    elsif @supplement_brand.destroy
      flash[:success] = 'Supplement brand was deleted.'
      redirect_to exchanges_path
    end
	end
	
  def import
		csv_file = File.read(params[:file].tempfile.to_path.to_s)
		SupplementBrand.import(csv_file)
		redirect_to import_all_path
  end
	
	private

		# Use callbacks to share common setup or constraints between actions.
    def set_supplement_brand
      @supplement_brand = SupplementBrand.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplement_brand_params
      params.require(:supplement_brand).permit(
        :name
      )
    end
    
    def authorized_to_change(supplement_brand)
			current_license == "owner" ||
			
			(current_license != "client" && 
       current_user.supplement_brands.include?(supplement_brand)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.supplement_brands.include?(supplement_brand)
			)
    end
    
    def authorized_to_see(supplement_brand)
			current_license == "owner" ||
			 
			exchange.user.license == "owner" ||
			
			(current_license != "client" && 
       current_user.supplement_brands.include?(supplement_brand)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.supplement_brands.include?(supplement_brand)
			)
    end
end