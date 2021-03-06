class ExchangesController < ApplicationController
	before_action :set_exchange, only: [:update, :destroy]
	
	def index
    if current_license != "owner" 
			if current_license != "client"
        
        if current_license == "employee"
          @my_exchanges           = current_user.employer.exchanges
          @my_sub_exchanges       = current_user.employer.sub_exchanges
          @my_foods               = current_user.employer.foods
        else
          @my_exchanges           = current_user.exchanges
          @my_sub_exchanges       = current_user.sub_exchanges
          @my_foods               = current_user.foods
        end
        
        owner_exchanges           = Exchange.joins(           :user).where(users: { license: "owner" })
        owner_sub_exchanges       = SubExchange.joins(        :user).where(users: { license: "owner" })
        owner_foods               = Food.joins(               :user).where(users: { license: "owner" })
        
      	@exchanges            = (@my_exchanges            || []) + (owner_exchanges           || [])
      	@sub_exchanges        = (@my_sub_exchanges        || []) + (owner_sub_exchanges       || [])
      	@foods                = (@my_foods                || []) + (owner_foods               || [])
			end
    else
      @exchanges              = Exchange.all
      @sub_exchanges          = SubExchange.all
      @foods                  = Food.all
      @my_exchanges           = @exchanges            
      @my_sub_exchanges       = @sub_exchanges
      @my_foods               = @foods
    end
	end
	
	def create
    if current_license == "client"
      flash[:danger] = "You are not authorized to create exchanges"
      redirect_to root_path
    else
      if current_license == "employee"
        @exchange = current_user.employer.exchanges.new(exchange_params)
      else      
        @exchange = current_user.exchanges.new(exchange_params)
      end

      if @exchange.save
        flash[:success] = 'Exchange was successfully created.'
        redirect_to exchanges_path
      else
        flash.now[:danger] = "Exchange failed to save!"
        render :index
      end
    end
	end
	
	def update
		if !authorized_to_change(@exchange)
      flash[:danger] = "You are not authorized to edit this exchange"
      redirect_to root_path
    else
    
      if @exchange.update(exchange_params)
        flash[:success] = 'Exchange was successfully updated.'
        redirect_to exchanges_path
      else
        flash.now[:danger] = "Changes failed to save"
        render :index
      end
		end
	end
	
	def destroy
    if !authorized_to_change(@exchange) || 
        current_license == "employee"
      flash[:danger] = "You are not authorized to delete this exchange"
      redirect_to root_path
    elsif @exchange.destroy
      flash[:success] = 'Exchange was deleted.'
      redirect_to exchanges_path
    end
	end

  def import
		csv_file = File.read(params[:file].tempfile.to_path.to_s)
		Exchange.import(csv_file)
		redirect_to import_all_path
  end
	
	private

		# Use callbacks to share common setup or constraints between actions.
    def set_exchange
      @exchange = Exchange.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exchange_params
      params.require(:exchange).permit(
        :name
      )
    end
    
    def authorized_to_change(exchange)
			current_license == "owner" ||
			
			(current_license != "client" && 
       current_user.exchanges.include?(exchange)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.exchanges.include?(exchange)
			)
    end
    
    def authorized_to_see(exchange)
			current_license == "owner" ||
			 
			exchange.user.license == "owner" ||
			
			(current_license != "client" && 
       current_user.exchanges.include?(exchange)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.exchanges.include?(exchange)
			)
    end
	
end
