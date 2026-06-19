class RequirementGap < ApplicationRecord
  SEVERITIES = %w[low medium high].freeze
  STATUSES = %w[open in_review resolved].freeze

  belongs_to :requirement
  belongs_to :assigned_to, class_name: "User", optional: true

  validates :title, :severity, :status, presence: true
  validates :severity, inclusion: { in: SEVERITIES }
  validates :status, inclusion: { in: STATUSES }

  after_save { RequirementStatusService.new(requirement).sync! }
end
