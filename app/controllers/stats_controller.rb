class StatsController < ApplicationController
  # GET /stats
  def show
    # Demandes d'habilitation déposées
    enrollment_count_query = <<-SQL
      SELECT COUNT(*) FROM enrollments;
    SQL
    enrollment_count = ActiveRecord::Base
                           .connection
                           .execute(enrollment_count_query)
                           .getvalue(0, 0)

    # Demandes d'habilitation validées
    validated_enrollment_count_query = <<-SQL
      SELECT COUNT(*) FROM enrollments WHERE status = 'validated';
    SQL
    validated_enrollment_count = ActiveRecord::Base
                                     .connection
                                     .execute(validated_enrollment_count_query)
                                     .getvalue(0, 0)

    # Temps moyen de traitement des demandes
    average_processing_time_in_days_query = <<-SQL
      SELECT avg(validation_duration)
      FROM (
        SELECT
          enrollments.id, events_start.created_at AS started_at, events_stop.created_at AS done_at,
          DATE_PART('days', events_stop.created_at - events_start.created_at) AS validation_duration
        FROM enrollments
        INNER JOIN
          events AS events_start ON events_start.enrollment_id = enrollments.id
          AND events_start.name = 'created'
        INNER JOIN
          events AS events_stop ON events_stop.enrollment_id = enrollments.id
          AND events_stop.name IN ('validated', 'refused')
        WHERE status IN ('validated', 'refused')
      ) e;
    SQL
    average_processing_time_in_days = ActiveRecord::Base
                                  .connection
                                  .execute(average_processing_time_in_days_query)
                                  .getvalue(0, 0)

    # Demandes d'habilitation déposées
    monthly_enrollment_count_query = <<-SQL
      SELECT
        date_trunc('month', created_at) AS month,
        COUNT(*)
      FROM enrollments
      GROUP BY month
      ORDER BY month;
    SQL
    monthly_enrollment_count = ActiveRecord::Base
                                   .connection
                                   .exec_query(monthly_enrollment_count_query)
                                   .to_hash()

    # Répartition des demandes par API
    enrollment_by_target_api_query = <<-SQL
      SELECT target_api AS name, COUNT(target_api) FROM enrollments GROUP BY target_api;
    SQL
    enrollment_by_target_api = ActiveRecord::Base
                                   .connection
                                   .exec_query(enrollment_by_target_api_query)
                                   .to_hash()

    # Répartition des demandes par statut
    enrollment_by_status_query = <<-SQL
      SELECT status AS name, count(status) FROM enrollments GROUP BY status;
    SQL
    enrollment_by_status = ActiveRecord::Base
                               .connection
                               .exec_query(enrollment_by_status_query)
                               .to_hash()

    render json: {
        enrollment_count: enrollment_count,
        validated_enrollment_count: validated_enrollment_count,
        average_processing_time_in_days: average_processing_time_in_days,
        monthly_enrollment_count: monthly_enrollment_count,
        enrollment_by_target_api: enrollment_by_target_api,
        enrollment_by_status: enrollment_by_status
    }
  end
end
