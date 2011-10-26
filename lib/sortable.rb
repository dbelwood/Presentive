module Sortable
	extend ActiveSupport::Concern

	included do
		field :position, :type => Integer

		default_scope asc(:position)

		# Assign position as last position
		before_save :assign_default_position 
		before_save :reorder_siblings
		after_destroy :move_lower_siblings_up

		def siblings
			[]
		end

		def move(new_index)
			@old_position = self.position
			self.position = new_index
		end
	end

	private
		def assign_default_position
			return unless self.position.nil?
			self.position = self.siblings.length
		end

		def reorder_siblings
			return if @old_position.nil?

			#Moved up
			self.siblings.where(:position.lt => @old_position).and(:position.gte => self.position).each do |s|
				s.inc(:position, 1)
			end

			#Moved down
			self.siblings.where(:position.gt => @old_position).and(:position.lte => self.position).each do |s|
				s.inc(:position, -1)
			end
		end

		def move_lower_siblings_up
			self.siblings.where(:position.gt => self.position).each { |s| s.inc(:position, -1) }
		end
end