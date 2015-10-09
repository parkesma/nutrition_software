class SupplementAssignmentsController < ApplicationController
	before_action :set_supplement_assignment, only: [:update, :destroy]

  def index
    if authorized_to_see
      @supplement_assignments = focussed_user.supplement_assignments.order(:time_of_day)
      @new_sa = focussed_user.supplement_assignments.new
      @my_supplement_products = SupplementProduct.joins(:user).where("users.license = ? OR users.id = ?", 
		    "owner", @new_sa.user.trainer_id ).distinct
    else
      flash[:danger] = "You are not authorized to view this client's supplements"
      redirect_to root_path
    end
  end
	
	def create
		if authorized_to_edit(focussed_user)
      
      params[:supplement_assignment][:number_of_servings] = 1 unless 
        params[:supplement_assignment][:number_of_servings]
      @supplement_assignment = focussed_user.supplement_assignments.build(supplement_assignment_params)

      if !@supplement_assignment.save
      	flash[:danger] = "Supplement assignment didn't save!"
      end
      redirect_to supplement_assignments_path
      
    else
      flash[:danger] = "You are not authorized to add supplements for this client"
      redirect_to root_path
		end
	end
	
	def update
		if authorized_to_edit(@supplement_assignment.user)
		  	  
      if @supplement_assignment.update_attributes(supplement_assignment_params)
         flash[:success] = "Supplement assignment updated"
      else
        flash[:danger] = "Supplement assignment didn't save!"
      end
      redirect_to supplement_assignments_path
      
    else
      flash[:danger] = "You are not authorized to edit this supplement assignment!"
      redirect_to root_path
		end
		
	end
	
	def destroy
		if authorized_to_edit(@supplement_assignment.user)
      @supplement_assignment.destroy
      flash[:success] = "Supplement assignment deleted"
      redirect_to supplement_assignments_path
    else
      flash[:danger] = "You are not authorized to delete this Supplement assignment!"
      redirect_to root_path
		end
	end
	
	private

		# Use callbacks to share common setup or constraints between actions.
    def set_supplement_assignment
      @supplement_assignment = SupplementAssignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplement_assignment_params
      params.require(:supplement_assignment).permit(
				:user_id, :supplement_product_id, :number_of_servings, :time_of_day
      )
    end
    
    def authorized_to_edit(user)
			current_license == "owner" ||
			
			(current_license != "client" && 
       current_user.clients.include?(user)
      )
    end
    
    def authorized_to_see
			current_license == "owner" ||
			 
			current_user == focussed_user ||
			
			(current_license != "client" && 
       current_user.clients.include?(focussed_user)
      )
    end
	
end
