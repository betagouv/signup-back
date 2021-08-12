class TeamMember::Demandeur < TeamMember
  def update(attributes)
    # this model cannot be edited
  end

  def disable_edition
    true
  end
end
