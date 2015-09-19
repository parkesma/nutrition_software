class SubExchangesController < ApplicationController
	before_action :set_sub_exchange, only: [:update, :destroy]
	
	def create
    if current_license == "client"
      flash[:danger] = "You are not authorized to create sub exchanges"
      redirect_to root_path
    else
      if current_license == "employee"
        @sub_exchange = current_user.employer.sub_exchanges.new(sub_exchange_params)
      else      
        @sub_exchange = current_user.sub_exchanges.new(sub_exchange_params)
      end

      if @sub_exchange.save
        flash[:success] = 'Sub exchange was successfully created.'
        redirect_to exchanges_path
      else
        flash[:danger] = "Sub exchange failed to save!"
        redirect_to exchanges_path
      end
    end
	end
	
	def update
		if !authorized_to_change(@sub_exchange)
      flash[:danger] = "You are not authorized to edit this sub exchange"
      redirect_to root_path
    else
    
      if @sub_exchange.update(sub_exchange_params)
        flash[:success] = 'Sub exchange was successfully updated.'
        redirect_to exchanges_path
      else
        flash[:danger] = "Changes failed to save"
        redirect_to exchanges_path
      end
		end
	end
	
	def destroy
    if !authorized_to_change(@sub_exchange) || 
        current_license == "employee"
      flash[:danger] = "You are not authorized to delete this sub exchange"
      redirect_to root_path
    elsif @sub_exchange.destroy
      flash[:success] = 'Sub exchange was deleted.'
      redirect_to exchanges_path
    end
	end
	
	private

		# Use callbacks to share common setup or constraints between actions.
    def set_sub_exchange
      @sub_exchange = SubExchange.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sub_exchange_params
      params.require(:sub_exchange).permit(
        :name, :exchange_id
      )
    end
    
    def authorized_to_change(sub_exchange)
			current_license == "owner" ||
			
			(current_license != "client" && 
       current_user.sub_exchanges.include?(sub_exchange)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.sub_exchanges.include?(sub_exchange)
			)
    end
    
    def authorized_to_see(sub_exchange)
			current_license == "owner" ||
			 
			sub_exchange.user.license == "owner" ||
			
			(current_license != "client" && 
       current_user.sub_exchanges.include?(sub_exchange)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.sub_exchanges.include?(sub_exchange)
			)
    end
	
end