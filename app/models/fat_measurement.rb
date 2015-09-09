class FatMeasurement < ActiveRecord::Base
	belongs_to :user
	
	def bf_options
		["Jackson/Pollock 3 (pref)",
		"Jackson/Pollock 4",
		"Jackson/Pollock 7",
		"Sloan",
		"Parillo",
		"Slaughter/Lohman",
		"US Navy",
		"Other"]
	end
	
	def method_fields
		if 	self.bf_method == "Jackson/Pollock 3 (pref)" || 
				self.bf_method.blank?
				
			if self.user.gender == "F"
				[
					:created_at,
					:weight,
					:tricep,
					:iliac_crest,
					:thigh
				]
			else
				[	
					:created_at,
					:weight,
					:chest,
					:abdomen,
					:thigh
				]
			end
		elsif self.bf_method == "Jackson/Pollock 4"
			[
				:created_at,
				:weight,
				:abdomen,
				:thigh,
				:tricep,
				:iliac_crest,
			]
		elsif self.bf_method == "Jackson/Pollock 7"
			[
				:created_at,
				:weight,
				:chest,
				:abdomen,
				:thigh,
				:tricep,
				:iliac_crest,
				:subscapular,
				:midaxillary
			]
		elsif self.bf_method == "Sloan" 
			if self.user.gender == "F"
				[
					:created_at,
					:weight,
					:iliac_crest,
					:tricep,
				]
			else
				[
					:created_at,
					:weight,
					:thigh,
					:subscapular
				]
			end
		elsif self.bf_method == "Parillo"
			[
				:created_at,
				:weight,
				:chest,
				:abdomen,
				:thigh,
				:tricep,
				:subscapular,
				:iliac_crest,
				:lower_back,
				:calf,
				:bicep
			]
		elsif self.bf_method == "Slaughter/Lohman"
			[
				:created_at,
				:weight,
				:calf,
				:tricep
			]
		elsif self.bf_method == "US Navy"
			if self.user.gender == "F"
				[
					:created_at,
					:weight,
					:abdomen,
					:neck,
					:hip
				]
			else
				[
					:created_at,
					:weight,
					:abdomen,
					:neck
				]
			end
		elsif self.bf_method == "Other"
			[
				:created_at,
				:weight,
				:measured_bf,
			]
		end
	end
	
	def calculated_bf
		age = self.user.age if !self.user.age.blank?

		if 	self.bf_method == "Jackson/Pollock 3 (pref)" || 
				self.bf_method.blank?
			
			if !age.blank?
			
			  if self.user.gender == "F"
			  	sum = self.tricep + self.iliac_crest + self.thigh if 
								!self.tricep.blank? && !self.iliac_crest.blank? && 
								!self.thigh.blank?
					
			  	body_density = 1.099421 - 0.0009929 * sum + 0.0000023 * 
			  		sum ** 2 - 0.0001392 * age if !sum.blank?
			  else
					sum = self.chest + self.abdomen + self.thigh if 
								!self.chest.blank? && !self.abdomen.blank? && 
								!self.thigh.blank?
								
			  	body_density = 1.10938 - 0.0008267 * sum + 
			  		0.0000016 * sum ** 2 - 0.0002574 * age if !sum.blank?
			  	
			  end
				495 / body_density - 450 if !body_density.blank?
			
			end

		elsif self.bf_method == "Jackson/Pollock 4"
			sum = self.abdomen + self.thigh + self.tricep + 
				self.iliac_crest if
				
				!self.abdomen.blank? && !self.thigh.blank? &&
				!self.tricep.blank? && !self.iliac_crest.blank?
			
			if !age.blank? && !sum.blank?
				if self.user.gender == "F"
					0.29669 * sum - 0.00043 * sum ** 2 + 0.02963 * age + 1.4072
				else
					0.29288 * sum - 0.0005 * sum ** 2 + 0.15845 * age - 5.76377
				end
			end
			
		elsif self.bf_method == "Jackson/Pollock 7"

			sum = self.tricep + self.iliac_crest + self.thigh + self.chest + 
						self.abdomen + self.subscapular + self.midaxillary if 

						!self.tricep.blank? && !self.iliac_crest.blank? &&
						!self.thigh.blank? && !self.chest.blank? && 
						!self.abdomen.blank? && !self.subscapular.blank? &&
						!self.midaxillary.blank?
						
			if !age.blank? && !(sum).blank?
			
				if self.user.gender == "F"
					body_density = 1.097 - (0.00046971 * sum) + 
	          (0.00000056 * (sum ** 2)) - (0.00012828 * age)

				else
        	body_density = 1.112 - (0.00043499 * sum) + 
                    (0.00000055 * (sum ** 2)) - (0.00028826 * age)

				end
          495 / body_density - 450
			end
			
		elsif self.bf_method == "Sloan"
			
			if self.user.gender == "F" && !self.iliac_crest.blank? && 
				!self.tricep.blank?
				
				body_density = 1.0764 - 0.0008 * self.iliac_crest - 0.00088 * 
					self.tricep
					
			elsif !self.thigh.blank? && !self.subscapular.blank?
				body_density = 1.1043 - 0.001327 * self.thigh - 0.00131 * 
					self.subscapular
					
			end
			495 / body_density - 450 if !body_density.blank?
			
		elsif self.bf_method == "Parillo"
			
			sum = self.chest + self.abdomen + self.thigh + self.tricep + 
				self.subscapular + self.iliac_crest + self.lower_back + 
				self.calf + self.bicep if 
				
				!self.chest.blank? && !self.abdomen.blank? && 
				!self.thigh.blank? && !self.tricep.blank? && 
				!self.subscapular.blank? && !self.iliac_crest.blank? && 
				!self.lower_back.blank? && !self.calf.blank? && !self.bicep.blank?
			
			sum * 27 / self.weight if !sum.blank? && !self.weight.blank?      
			
		elsif self.bf_method == "Slaughter/Lohman"
		
			if !self.tricep.blank? && !self.calf.blank?
				if self.user.gender == "F"
				
					0.610 * (self.tricep + self.calf) + 5.1
				
				else
		    	0.735 * (self.tricep + self.calf) + 1.0
				end
			end
			
		elsif self.bf_method == "US Navy"
		
			if !self.user.height.blank? && self.user.gender == "F" && 
					!self.abdomen.blank? && !self.hip.blank? && !self.neck.blank?
				163.205 * Math.log10(self.abdomen + self.hip - self.neck) - 
					97.684 * Math.log10(self.user.height) - 78.387
			
			elsif !self.abdomen.blank? && !self.neck.blank?
				86.010 * Math.log10(self.abdomen - self.neck) - 70.041 * 
					Math.log10(self.user.height) + 36.77
			
			end	
			
		elsif self.bf_method == "Other"
			self.measured_bf
		end
	end
	
	def lean_mass
		self.weight - self.weight * 
		self.calculated_bf / 100 if
		!self.weight.blank? && !self.calculated_bf.blank?
	end
	
	def fat_mass
		self.weight * self.calculated_bf / 100 if
		!self.weight.blank? && !self.calculated_bf.blank?
	end
	
	def previous_measure
		my_date = self.created_at || Date.today
		
		self.user.fat_measurements.where(
				'id != ? AND created_at < ?',
				self.id,			my_date).
				order(:created_at).last
	end
	
	def bf_change
		self.calculated_bf - 
			previous_measure.calculated_bf if 
			!self.calculated_bf.blank? && 
			!self.previous_measure.blank? &&
			!self.previous_measure.calculated_bf.blank?
	end
	
	def lean_mass_change
		self.lean_mass - previous_measure.lean_mass if 
			!self.lean_mass.blank? && 
			!self.previous_measure.blank? &&
			!self.previous_measure.lean_mass.blank?
	end
	
	def fat_mass_change
		self.fat_mass - previous_measure.fat_mass if 
			!self.fat_mass.blank? && 
			!self.previous_measure.blank? &&
			!self.previous_measure.fat_mass.blank?
	end
	
end