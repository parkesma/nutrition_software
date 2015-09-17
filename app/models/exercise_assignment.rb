class ExerciseAssignment < ActiveRecord::Base
	belongs_to :user
	belongs_to :exercise
	
	def kcal_per_hr
		if user.fat_measurements.order(:created_at).last
			weight = user.fat_measurements.order(:created_at).last.weight
		else
			weight = user.present_weight
		end
		
		if weight && exercise
			(exercise.Kcal_per_kg_per_hr * weight / 2.2).round(2)
		end
	end
	
	def weekly_kcal
		if kcal_per_hr && self.hrs_per_wk
			(kcal_per_hr * self.hrs_per_wk).round(2)
		end
	end
	
	def daily_kcal
		(weekly_kcal / 7).round(2) if weekly_kcal
	end

end
