class ExerciseAssignmentsController < ApplicationController
	before_action :set_exercise_assignment, only: [
		:update, :destroy, :move_up, :move_down
	]
	
	def index
		trainer_exercises = focussed_user.trainer.exercises if 
			focussed_user.trainer
    owner_exercises = Exercise.joins(:user).
      where(users: { license: "owner" })

    if trainer_exercises
    	if owner_exercises
    		@possible_exercises = trainer_exercises + owner_exercises
    	else
    		@possible_exercises = trainer_exercises
    	end
    else
    	@possible_exercises = owner_exercises
    end
		
		all_assignments = focussed_user.exercise_assignments
		
		@cardio = all_assignments.joins(:exercise).
			where("category = ?", "Cardiovascular").order(:position)
			
		i = 0
		@cardio.map { 
			|e| e.position = i
			e.save
			i += 1

		}
		
		@resistance = all_assignments.joins(:exercise).
			where("category = ?", "Resistance").order(:position)

		i = 0
		@resistance.map { 
			|e| e.position = i
			e.save
			i += 1
		}
		
		@daily_average_kcal = 0
		all_assignments.each do |a|
			@daily_average_kcal += a.daily_kcal if a.daily_kcal
		end

	end
	
	def create
		if !authorized_to_change
      flash[:danger] = "You are not authorized to assign exercises"
      redirect_to root_path
    elsif focussed_user.exercise_assignments.create(
    		exercise_assignment_params)
			flash[:success] = 'Exercise was successfully assigned'
    	redirect_to exercise_assignments_path
		else
			flash[:danger] = "Exercise assignment failed!"
      redirect_to exercise_assignments_path
		end
	end
	
	def update
		if !authorized_to_change
     flash[:danger] = "You are not authorized to delete this exercise"
     redirect_to root_path
  	elsif @exercise_assignment.update(exercise_assignment_params)
  		flash[:success] = 'Exercise was deleted.'
			redirect_to exercise_assignments_path
		else
			flash[:danger] = 'Exercise assignment failed to save.'
			redirect_to exercise_assignments_path
		end
	end
	
	def move_up
		above = focussed_user.exercise_assignments.where(
			"position = ?", @exercise_assignment.position - 1)
		above.update_all(position: @exercise_assignment.position) if above.size > 0
		@exercise_assignment.update(position: @exercise_assignment.position - 1)
		redirect_to exercise_assignments_path
	end
	
	def move_down
		below = focussed_user.exercise_assignments.where(
			"position = ?", @exercise_assignment.position + 1)
		below.update_all(position: @exercise_assignment.position) if below.size > 0
		@exercise_assignment.update(position: @exercise_assignment.position + 1)
		redirect_to exercise_assignments_path
	end
		
	def destroy
		if !authorized_to_change
			flash[:danger] = "You are not authorized to delete this exercise"
			redirect_to root_path
		elsif @exercise_assignment.destroy
			flash[:success] = 'Exercise was removed from plan.'
			redirect_to exercise_assignments_path
		else
			flash[:danger] = 'Exercise was not removed from plan.'
			redirect_to exercise_assignments_path
		end
	end
	
	private
		def exercise_assignment_params
			params.require(:exercise_assignment).permit(
				:hrs_per_wk, :exercise_id
			)
		end
		
		def set_exercise_assignment
			@exercise_assignment = ExerciseAssignment.find(params[:id])
		end
    
    def authorized_to_see
			current_license == "owner" ||
			focussed_user == current_user ||
			current_user.clients.include?(focussed_user)
    end

		def authorized_to_change
			current_license == "owner" ||
			current_user.clients.include?(focussed_user)
		end
	
end
