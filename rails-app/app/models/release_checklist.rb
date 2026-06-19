class ReleaseChecklist < ApplicationRecord
  belongs_to :release

  STAGING_FIELDS = %i[code_review_completed unit_tests_passed qa_verified db_migration_reviewed].freeze
  PRODUCTION_FIELDS = %i[rollback_plan_added staging_deployment_done production_approval_received].freeze

  def staging_complete?
    STAGING_FIELDS.all? { |field| public_send(field) }
  end

  def production_complete?
    PRODUCTION_FIELDS.all? { |field| public_send(field) }
  end
end
