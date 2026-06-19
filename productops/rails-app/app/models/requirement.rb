class Requirement < ApplicationRecord
  PRIORITIES = %w[low medium high critical].freeze
  STATUSES = %w[draft needs_clarification ready_for_estimation in_development released].freeze

  belongs_to :project
  belongs_to :created_by, class_name: "User"
  belongs_to :assigned_owner, class_name: "User", optional: true
  has_many :requirement_gaps, dependent: :destroy
  has_many :clarification_questions, dependent: :destroy
  has_many :decision_notes, dependent: :destroy
  has_many :wbs_items, dependent: :destroy

  validates :title, :priority, :status, presence: true
  validates :priority, inclusion: { in: PRIORITIES }
  validates :status, inclusion: { in: STATUSES }
  validate :must_have_wbs_before_development

  scope :active, -> { where(deleted_at: nil) }

  def open_gaps?
    requirement_gaps.where.not(status: "resolved").exists?
  end

  private

  def must_have_wbs_before_development
    return unless status == "in_development" && wbs_items.none?
    errors.add(:status, "requires at least one WBS item before development")
  end
end
