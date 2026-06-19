class Deployment < ApplicationRecord
  belongs_to :release
  belongs_to :deployed_by, class_name: "User", optional: true

  validates :environment, inclusion: { in: Release::ENVIRONMENTS }
  validates :status, inclusion: { in: %w[pending running success failed rolled_back] }
  validates :rollback_reason, presence: true, if: -> { status == "rolled_back" }
end
