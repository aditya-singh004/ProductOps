class Sprint < ApplicationRecord
  STATUSES = %w[planning active completed cancelled].freeze

  belongs_to :project
  has_many :wbs_items, dependent: :nullify
  has_many :risk_reports, dependent: :nullify

  validates :name, :start_date, :end_date, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :end_date_after_start_date

  def summary
    WbsEstimationService.new(wbs_items).summary
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank? || end_date >= start_date
    errors.add(:end_date, "must be on or after start date")
  end
end
