class Note < ActiveRecord::Base
	belongs_to :user
	
	def author
		User.find_by(id: author_id)
	end
	
end
