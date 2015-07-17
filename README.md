# tagging-categories
Reference for Tagging an Categories in Rails Using Foundation
This is the start of a blog post I will eventually put up online to be used for 
people learning Rails and wanting to know more about databases and associations. 

The following are only my notes for when I come back to complete the lesson. 

A many to many relationship can be represented by an associaion in Rails in the following ways.

1. Use a has_and_belongs_to_many (habtm) association. This creates a join table in the database, but doesn't create the model for the join. In other words you won't be able to create attributes to the join or validations. 

2. Use of a has_and_many, through requires a model for the join table. 
You can generate the model like so: (Note you can include the assocations when generating th model.)

	`rails g model post author:string content:text`
	
	`rails g model tagging post:belongs_to tag:belongs_to ` 

The last rails generation creates a model like so:
```
class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.belongs_to :project, index: true, foreign_key: true
      t.belongs_to :tag, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
```
The Taggings table is the join table between Projects and Tags.

To handle the creation of Tags as part of the Project Create form, we define a method, to take all of the tags and stip them and then wrote each tag to the database. 
```
def all_tags=(names)
		self.tags = names.split(", ").map do |name|
			Tag.where(name: name.strip).first_or_create!
		end
	end
```
The Project model holds two attributes, pro and content. The attribute for all_tags will be added to the form as well. 
We create another method to render all of the tags seperated by commas called all_tags.
```
def all_tags 
	self.tags.map(&:name).join(", ")
end
```
Time to bring on the Foundation. 

`rails g foundation:install`

Generate controller for Project. 
Shortcut Hint:After rails g controller modelname enter index and create. This will add the method sytax for you in your controller like so:

```
class ProjectsController < ApplicationController
  def index
  	
  end

  def create
  end
end
```
We then create strong params including the virtualattributes. Virtual atributes are simplely defined as getter and setter methods and can be included in string params. 

```
private 
def project_params 
	params.require(:project).permit(:pro, :content, :all_tags)
end
```

Lets create the form"
```
<div class="row text-center">
	<%= form_for(Project.new, remote: true) do |f| %>
		<div class"large-10 large centered columns">
			<%= f.text_field :pro, placeholder: "Pro Name" %>
		</div>
		<div class"large-10 large centered columns">
			<%= f.text_field :content, placeholder: "Tags seperated with ," %>
		</div>
		<div class"large-10 large centered columns">
			<%= f.submit :project, class: "button" %>
		</div>
		<% end %>
		</div>
</div>
```

The remote: true is an attribute that tells the form to submit via ajax rather than the browser mechanism.
It will then redirect to the index action and view the existing projects. 

Foundation didn't go as easy as I thought it would or render perhaps what I wanted it to. I find Bootstrap easier to set up. Maybe because I'm more famliar with it. 

Tag Based Search

Creating a scope based search in a tag name is as easy as creating a class method called tagged_with(name) which will take the name of the specified tag and search projects associated with it. 
 In projects model create:

```
def self.tagged_with(name)
	Tag.find_by_name!(name).projects
end
```

Then in controller create an instance variable to hold the results on the controller. 

```
def index
	if params[:tag]
		@projects = Project.tagged_by(params[:tag])
	else
		@projects = Project.all
	end
end
```
Just make sure you upate your routes for the search result. 

`get 'tags/:tag', to: 'projects#index', as: "tag"`


Oh and in the views make sure you add:

`<%=raw tag_links(project.all_tags) %> `
(the raw just strips out the string and ensures that the tags stay within the link.)

... and you could do a helper which creates the links_to in other words it will hold the logic of converting the tags to links like so:

```
def tag_links(tags)
	tags.split(",").map{|tag| link_to tag.strip, tag_path(tag.strip) }.join(", ")
end
```
Pretty sweet eh?

We can make a tag cloud to go even further this will give you an idea of how to display popular projects or posts or whatever you're working on. 

We need to create the method in the tags model. 

```
def self.counts
	self.select("name, count(taggings.tag_id) as count").joins(:taggings).group("taggings.tag_id")
end
```

So what we've just done is created a query that groups the matched tag_ids from the taggings join table and counts them all up. 
We can style them with a helper method called tag_cloud by taking the result of calling the counts function and CSS classes. 

...in the project helper folder do the following:

```
def tag_cloud(tags, classes)
	max = tags.sort_by(&:count).last
	tags.each do |tag|
	index = tag.count.to_f / max.count * (classes.size-1)
	yield(tag, classes[index.round])
	end
end
```

