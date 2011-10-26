class Presentation
	include Mongoid::Document

	field :name, type: String
	field :author, type: String

	embeds_many :slides
end