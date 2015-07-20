class User < ActiveRecord::Base
	validates :username, presence: true,
	                     uniqueness: { case_sensitive: false }
	validates :password, presence: true
	has_many :top_down_relationships, class_name: "Relationship",
	                                  foreign_key: "sub_id",
	                                  dependent: :destroy
	has_many :subs, through: :top_down_relationships, source: "sub"
	has_one :bottom_up_relationship, class_name: "Relationship",
	                                 foreign_key: "sup_id",
	                                 dependent: :destroy
  has_one :sup, through: :bottom_up_relationship, source: "sup"
	#has_many :planned_foods, through _
	#has_many :planned_exercises, through _
	#has_many :measurements, through _
	#has_many :bf_measurements, through _
	
	def clients
		#all_subs = self.subs.all
		if self.license == "employer" || self.license == "trainer"
			trainer_id = self.id
		elsif self.license = "employee"
			trainer_id = self.employer.id
		else
			trainer_id = nil
		end
		
		all_r = Relationship.where(sup_id: trainer_id)
		clients = Array.new
		
		all_r.each do |s|
			User.all.each do |u|
		  	if u.id == s.sub_id && u.license == "client"
			  	clients.push(u)
		  	end
			end
	  end
		
		return clients
	end

	def employees
		#all_subs = self.subs.all
		all_r = Relationship.where(sup_id: self.id)
		employees = Array.new
		all_r.each do |s|
			User.all.each do |u|
			  if u.id == s.sub_id && u.license == "employee"
			  	employees.push(u)
			  end
			end
	  end
		return employees
	end
	
	def trainer
		all_r = Relationship.where(sub_id: self.id)
		trainer = nil
		all_r.each do |s|
			User.all.each do |u|
			  if u.id == s.sup_id && (u.license == "employer" || u.license == "trainer") 
			  	trainer = u
			  end
			end
	  end
		return trainer
	end
	
	alias_method :employer, :trainer
end