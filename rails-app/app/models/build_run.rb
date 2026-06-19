class BuildRun < ApplicationRecord
  belongs_to :project

  validates :build_tool, inclusion: { in: %w[ant] }
  validates :status, inclusion: { in: %w[success failed running] }
  validates :duration_seconds, :failed_test_count, numericality: { greater_than_or_equal_to: 0 }
end
