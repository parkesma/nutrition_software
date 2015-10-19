class VideosController < ApplicationController
	before_action :set_video, only: [:update, :destroy, :move_up, :move_down]
	before_action :check_license, only: [:create, :update, :destroy, :move_up, :move_down]
	
	def index
		@videos = Video.all.order(:position)
		count = 1
		@videos.each do |video|
			if video.position.blank?
				video.update(position: count)
			end
			count += 1
		end
	end
	
	def create
		@video = Video.new(video_params)
		if @video.save
			flash[:success] = 'Video saved'
    else
    	flash[:danger] = 'Video failed to save'
		end
    redirect_to videos_path
	end
	
	def update
		if @video.update(video_params)
			flash[:success] = 'Video saved'
    else
    	flash[:danger] = 'Video failed to save'
		end
    redirect_to videos_path
	end
	
	def destroy
		if @video.destroy
			flash[:success] = 'Video deleted'
    else
    	flash[:danger] = 'Video failed to delete'
		end
    redirect_to videos_path
	end
	
	def move_up
		above = Video.where("position = ?", @video.position - 1)
		above.update_all(position: @video.position) if above.size > 0
		@video.update(position: @video.position - 1)
		redirect_to videos_path
	end
	
	def move_down
		below = Video.where("position = ?", @video.position + 1)
		below.update_all(position: @video.position) if below.size > 0
		@video.update(position: @video.position + 1)
		redirect_to videos_path
	end

	private
		def video_params
			params.require(:video).permit(:title, :url, :description)
		end
		
		def set_video
			@video = Video.find(params[:id])
		end
		
		def check_license
			if current_license != "owner"
				flash[:danger] = "You are not authorized to change videos."
				redirect_to videos_path
			end
		end
	
end