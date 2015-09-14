class ExercisesController < ApplicationController
  before_action :set_exercise, only: [:show, :edit, :update, :destroy]

  def index

    if current_license == "employee"
      @my_exercises = current_user.employer.exercises
    elsif current_license != "client"
      @my_exercises = current_user.exercises
    end
    
    if current_license == "client"
      @trainer_exercises = current_user.trainer.exercises
    end

    @owner_exercises = Exercise.joins(:user).
      where(users: { license: "owner" })

    if current_license != "owner"
      @exercises = (@my_exercises || []) + (@owner_exercises || []) +
        (@trainer_exercises || [])
    else
      @exercises = Exercise.all
    end
    
    @authorized_to_change = authorized_to_change(@exercise)
    @cardio , @resistance = [], []
    @exercises.each do |exercise|
      @cardio << exercise if exercise.category == 'Cardiovascular'
      @resistance << exercise if exercise.category == 'Resistance'
    end
  end

  def show
    if !authorized_to_see(@exercise)
      flash[:danger] = "You are not authorized to see that exercise"
      redirect_to root_path
    end
    @authorized_to_change = authorized_to_change(@exercise)
  end

  # GET /exercises/new
  def new
    if current_license == "client"
      flash[:danger] = "You are not authorized to create exercises"
      redirect_to root_path
    else
      @exercise = Exercise.new
    end
  end

  # GET /exercises/1/edit
  def edit
    if !authorized_to_change(@exercise)
      flash[:danger] = "You are not authorized to edit this exercise"
      redirect_to root_path
    end
  end

  def create
    if current_license == "client"
      flash[:danger] = "You are not authorized to create exercises"
      redirect_to root_path
    else
      if current_license == "employee"
        @exercise = current_user.employer.exercises.new(exercise_params)
      else      
        @exercise = current_user.exercises.new(exercise_params)
      end

      if @exercise.save
        flash[:success] = 'Exercise was successfully created.'
        redirect_to exercises_path
      else
        flash.now[:danger] = "Exercise failed to save!"
        render :new
      end
    end
  end

  def update
    if !authorized_to_change(@exercise)
      flash[:danger] = "You are not authorized to edit this exercise"
      redirect_to root_path
    else
    
      if @exercise.update(exercise_params)
        flash[:success] = 'Exercise was successfully updated.'
        redirect_to exercises_path
      else
        flash.now[:danger] = "Changes failed to save"
        render :edit
      end
    end
  end

  def destroy
    if !authorized_to_change(@exercise) || 
        current_license == "employee"
      flash[:danger] = "You are not authorized to delete this exercise"
      redirect_to root_path
    elsif @exercise.destroy
      flash[:success] = 'Exercise was deleted.'
      redirect_to exercises_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exercise
      @exercise = Exercise.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exercise_params
      params.require(:exercise).permit(
        :name, :description, :Kcal_per_kg_per_hr, :category
      )
    end
    
    def authorized_to_change(exercise)
			current_license == "owner" ||
			
			(current_license != "client" && 
       current_user.exercises.include?(exercise)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.exercises.include?(exercise)
			)
    end
    
    def authorized_to_see(exercise)
			current_license == "owner" ||
			 
			exercise.user.license == "owner" ||
			
			(current_license != "client" && 
       current_user.exercises.include?(exercise)
      ) ||
      
			(current_license == "employee" &&
			 current_user.employer.exercises.include?(exercise)
			) ||
			
			(current_license == "client" &&
			  current_user.trainer.exercises.include?(exercise)
			)
    end

end
