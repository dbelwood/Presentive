require 'sortable'

class Slide
	include Mongoid::Document
	include Sortable

	field :title, type: String 
	field :subtitle, type: String 

	def siblings
		self.presentation.slides.where(:_id.ne => self.id)
	end

	def inspect
		"{ Title: #{self.title}, 
		   Subtitle: #{self.subtitle},
		   Position: #{self.position}
		}"
	end

	embedded_in :presentation
	embeds_many :slide_parts
end