class Enrollment::LeTaxiPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :operator,
        :search_engine,
      ],
    ])

    res
  end
end
