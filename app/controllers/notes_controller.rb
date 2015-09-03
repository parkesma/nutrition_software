class NotesController < ApplicationController
	
	def index
	  @notes = focussed_user.notes.order("updated_at DESC")
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
	  @note = Note.find_by(id: params[:id])
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
    
    else
      flash[:danger] = "You are not authorized to edit this note!"
    end
    redirect_to notes_path
	end
  
  def destroy
    @note = Note.find_by(id: params[:id])

    if (current_license != "client" && 
        current_user.clients.include?(@note.user)) ||
        current_license == "owner"

      @note.destroy
      flash[:success] = "Note deleted"
    else
      flash[:danger] = "You are not authorized to delete this note!"
    end
    redirect_to notes_path
  end

	private
	
		def note_params
			params.require(:note).permit(
				:text
			)
		end
  
end
