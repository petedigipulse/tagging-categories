class Project < ActiveRecord::Base
	has_many :taggings
	has_many :tags, through: :taggings

	def all_tags=(names)
		self.tags = names.split(", ").map do |name|
			Tag.where(name: name.strip).first_or_create!
		end
	end

	def all_tags
		self.tags.map(&:name).join(", ")
	end
	#Tag-based search
	def self.tagged_with(name)
		Tag.find_by_name!(name).projects
	end

	
end
