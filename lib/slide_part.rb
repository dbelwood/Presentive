require 'sortable'
require 'image_uploader'
require 'rdiscount'

class SlidePart
	include Mongoid::Document
	include Sortable

	field :content, type: String
	field :path, type: String
	field :slide_type, type: Symbol

	validates_presence_of :slide_type
	validates_inclusion_of :slide_type, in: [:image, :markdown]

	def siblings
		self.slide.slide_parts.where(:_id.ne => self.id)
	end

	def inspect
		"{
			type: #{self.type},
			content: #{self.content},
			path: #{self.path}
		}"
	end

	def content_html
		RDiscount.new(self.content).to_html
	end

	embedded_in :slide
	mount_uploader :image, ImageUploader
end