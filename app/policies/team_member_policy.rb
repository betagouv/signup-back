class TeamMemberPolicy < ApplicationPolicy
  # TODO all team_member visible only if user is demandeur or admin ?
  # TODO update? only for demandeur
  # def update?
  #   user.is_administrator?
  # end

  # TODO pointless fornow

  def show?
    user.is_member?(record.enrollment)
  end

  def create?
    user.is_demandeur?(record.enrollment)
  end

  def update?
    user.is_demandeur?(record.enrollment)
  end
end
