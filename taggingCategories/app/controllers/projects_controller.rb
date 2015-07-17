class ProjectsController < ApplicationController
  def index
    if params[:tag]
      @projects = Project.tagged_with(params[:tag])
    else
    	@projects = Project.all
    end
  end

  def create
  	@project = Project.new(project_params)
  	respond_to do |format|
  		if @project.save
  			format.js # Will search for create.js
  		else
  			format.html {render root_path}
  		end
  	end
  end
  

  private 
  def project_params 
  	params.require(:project).permit(:pro, :content, :all_tags)
  end
end
