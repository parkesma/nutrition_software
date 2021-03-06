class NotesController < ApplicationController
  before_action :date_check, only: [:create, :update]
	
	def index
    if current_license != "client"
	    @notes = focussed_user.notes.order("updated_at DESC")
    else
	    redirect_to root_path
    end
	end
	
	def create
    if (current_license != "client" && 
        current_user.clients.include?(focussed_user)) ||
        current_license == "owner"
      @note = focussed_user.notes.build(note_params)
      @note.author_id = current_user.id
      
      if @note.save
        flash[:success] = "Note created"
      else
      	flash[:danger] = "Note didn't save!"
      end
    
    else
      flash[:danger] = "You are not authorized to create this note!"
    end
    redirect_to notes_path
	end
	
	def edit
    if current_license != "client"
	    @note = Note.find_by(id: params[:id])
    else
	    redirect_to root_path
    end
	end
	
	def update
	  @note = Note.find_by(id: params[:id])
    if (current_license != "client" && 
        current_user.clients.include?(@note.user)) ||
        current_license == "owner"
      @note.author_id = current_user.id
      
      if @note.update_attributes(note_params)
        flash[:success] = "Note updated"
      else
      	flash[:danger] = "Note didn't save!"
      end
      redirect_to notes_path
      
    else
      flash[:danger] = "You are not authorized to edit this note!"
      redirect_to root_path
      
    end
	end
  
  def destroy
    @note = Note.find_by(id: params[:id])

    if (current_license != "client" && 
        current_user.clients.include?(@note.user)) ||
        current_license == "owner"

      @note.destroy
      flash[:success] = "Note deleted"
      redirect_to notes_path
    else
      flash[:danger] = "You are not authorized to delete this note!"
      redirect_to root_path
      
    end
  end

	private
	
		def note_params
			params.require(:note).permit(
				:text, :updated_at
			)
		end
		
    def date_check
			master_date_check(note_params[:updated_at])
    end

  
end