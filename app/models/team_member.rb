class TeamMember < ActiveRecord::Base
  # as I really wanted to use my type column for my own usage
  # I override the default column used for inheritance
  # TODO maybe we can actually use inheritance to implement rules by roles
  self.inheritance_column = :kind

  belongs_to :enrollment
  belongs_to :user
end
