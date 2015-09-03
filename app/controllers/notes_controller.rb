class NotesController < ApplicationController
	
	def index
	  @notes = focussed_user.notes.order("updated_at DESC")
	end
	
	def create
    @note = focussed_user.notes.build(note_params)
    @note.author_id = current_user.id
    if @note.save
      flash[:success] = "Note created"
      redirect_to notes_path
    else
    	flash.now[:danger] = "Note didn't save!"
      render notes_path
    end
	end
  
  def destroy
    @note.destroy
    flash[:success] = "Note deleted"
    redirect_to root_url
  end

	private
	
		def note_params
			params.require(:note).permit(
				:text
			)
		end
  
end
