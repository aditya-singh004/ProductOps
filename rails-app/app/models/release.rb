class Release < ApplicationRecord
  STATUSES = %w[draft checklist_pending risk_review staging_ready production_ready deployed rolled_back].freeze
  ENVIRONMENTS = %w[staging production].freeze

  belongs_to :project
  belongs_to :sprint, optional: true
  belongs_to :release_owner, class_name: "User"
  has_one :release_checklist, dependent: :destroy
  has_many :deployments, dependent: :destroy
  has_many :risk_reports, dependent: :nullify

  validates :version_number, :title, :environment, :status, presence: true
  validates :version_number, uniqueness: { scope: :project_id }
  validates :environment, inclusion: { in: ENVIRONMENTS }
  validates :status, inclusion: { in: STATUSES }

  after_create :ensure_checklist

  def latest_risk_report
    risk_reports.order(created_at: :desc).first || sprint&.risk_reports&.order(created_at: :desc)&.first
  end

  private

  def ensure_checklist
    create_release_checklist! unless release_checklist
  end
end
