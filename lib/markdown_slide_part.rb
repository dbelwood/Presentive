class MarkdownSlidePart < SlidePart
	include Mongoid::Document

	field :content, type: String
end