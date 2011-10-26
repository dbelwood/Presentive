class ImageSlidePart < SlidePart
	include Mongoid::Document

	field :path, type: String
end