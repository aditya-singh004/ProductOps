class WbsItem < ApplicationRecord
  CATEGORIES = %w[backend frontend database qa deployment documentation rollback].freeze
  STATUSES = %w[backlog todo in_progress code_review qa done blocked].freeze
  LEVELS = %w[low medium high].freeze

  belongs_to :requirement
  belongs_to :sprint, optional: true
  belongs_to :owner, class_name: "User", optional: true
  has_many :outgoing_dependencies, class_name: "TaskDependency", foreign_key: :predecessor_task_id, dependent: :destroy
  has_many :incoming_dependencies, class_name: "TaskDependency", foreign_key: :successor_task_id, dependent: :destroy
  has_many :successor_tasks, through: :outgoing_dependencies, source: :successor_task
  has_many :predecessor_tasks, through: :incoming_dependencies, source: :predecessor_task
  has_many :svn_commits, dependent: :nullify

  validates :title, :category, :complexity, :risk_level, :status, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :complexity, :risk_level, inclusion: { in: LEVELS }
  validates :status, inclusion: { in: STATUSES }
  validates :estimated_hours, numericality: { greater_than: 0 }
  validates :actual_hours, numericality: { greater_than_or_equal_to: 0 }
  validates :blocked_reason, presence: true, if: -> { status == "blocked" }

  before_validation :assign_task_key, on: :create
  before_validation :raise_high_complexity_risk

  scope :active, -> { where(deleted_at: nil) }

  def overdue?
    due_date.present? && due_date < Date.current && status != "done"
  end

  def blocked?
    status == "blocked"
  end

  private

  def assign_task_key
    self.task_key ||= "PO-#{SecureRandom.random_number(900) + 100}"
  end

  def raise_high_complexity_risk
    self.risk_level = "medium" if complexity == "high" && risk_level == "low"
  end
end
