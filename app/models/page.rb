class Page < ActiveRecord::Base
  acts_as_context_item
  acts_as_content_holder
  acts_as_taggable_by_user
  
  def move_to_project(project_or_id)
    project = if project_or_id.is_a?(Project)
        project_or_id
      else 
        Project.find(project_or_id)
      end
    if project
      self.context = project.context
      self.save!
    end
  end

  validates_presence_of :title
  validates_uniqueness_of :title
end
