class Enrollment::ApiParticulier < Enrollment
  resourcify

  def short_workflow?
    true
  end
end
